package main

import (
	"database/sql"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/MarcusWalz/sleepy"
	_ "github.com/go-sql-driver/mysql"
)

type Measurement struct {
}

type MeasurementData struct {
	ID        int     `json:"id"`
	CreatedAt string  `json:"created_at"`
	Lux       int     `json:"lux"`
	Drewpoint float32 `json:"drewpoint"`
	Humidity  float32 `json:"humidity"`
	Temp      float32 `json:"temp"`
	Soil      float32 `json:"soil"`
	Bar       float32 `json:"bar"`
}

func (item Measurement) Get(request *http.Request) (int, interface{}, http.Header) {

	rows, err := db.Query("SELECT * FROM measurements")
	checkErr(err)

	items := []MeasurementData{}
	for rows.Next() {
		measurement := new(MeasurementData)
		err = rows.Scan(&measurement.ID, &measurement.CreatedAt, &measurement.Lux, &measurement.Drewpoint, &measurement.Humidity, &measurement.Temp, &measurement.Bar, &measurement.Soil)
		checkErr(err)
		items = append(items, *measurement)
	}

	data := map[string][]MeasurementData{"measurements": items}
	return 200, data, http.Header{"Content-type": {"application/json"}}
}

func (item Measurement) Post(request *http.Request) (int, interface{}, http.Header) {
	var measurement MeasurementData
	decoder := json.NewDecoder(request.Body)

	err := decoder.Decode(&measurement)

	if err != nil && err.Error() != "EOF" {
		panic(err)
	}
	fmt.Println(measurement)

	// {"lux":384,"drewpoint":"9.94","humidity":"41.094","temp":"23.95","soil":"0.09","bar":"998.438"}
	// Prepare statement for inserting data
	stmt, err := db.Prepare("INSERT INTO measurements (lux, drewpoint, humidity, temp, soil, bar) VALUES( ?, ?, ?, ?, ?, ? )") // ? = placeholder
	checkErr(err)
	defer stmt.Close() // Close the statement when we leave main() / the program terminates

	rows, err := stmt.Query(measurement.Lux, measurement.Drewpoint, measurement.Humidity, measurement.Temp, measurement.Soil, measurement.Bar)

	defer rows.Close()
	if err != nil {
		log.Fatal(err)
		return 422, measurement, http.Header{"Content-type": {"application/json"}}

	} else {
		return 201, measurement, http.Header{"Content-type": {"application/json"}}
	}
}

func main() {
	initDB()
	item := new(Measurement)

	api := sleepy.NewAPI()
	api.AddResource(item, "/measurements")
	api.Start(3000)
}

func checkErr(err error) {
	if err != nil {
		panic(err)
	}
}

func initDB() {
	flag.Parse()

	args := flag.Args()
	if len(args) < 1 {
		fmt.Println("no DB Login defined!")
		os.Exit(1)
	}
	var err error
	db, err = sql.Open("mysql", args[0]+"@/greenhouse")
	checkErr(err)
	result, err := db.Exec(createsql)
	fmt.Println(result.LastInsertId())
	fmt.Println(result.RowsAffected())
	checkErr(err)
}

var db *sql.DB

// {"lux":384,"drewpoint":"9.94","humidity":"41.094","temp":"23.95","soil":"0.09","bar":"998.438"}
const createsql string = "CREATE TABLE IF NOT EXISTS measurements (id INT(11) NOT NULL AUTO_INCREMENT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, lux INT, drewpoint DECIMAL(8,2), humidity DECIMAL(8,3), temp DECIMAL(8,2), soil DECIMAL(8,2), bar DECIMAL(8,3), PRIMARY KEY (id)) ENGINE=InnoDB"
