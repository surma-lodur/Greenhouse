package main

import (
	"database/sql"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/MarcusWalz/sleepy"
	_ "github.com/go-sql-driver/mysql"
	"github.com/rs/cors"
	"superbösewicht.de/Greenhouse/mapper"
)

type Measurement struct{}

func (item Measurement) Get(request *http.Request) (int, interface{}, http.Header) {
	start_date := request.FormValue("start_date")
	end_date := request.FormValue("end_date")
	items := mapper.GetAll(db, start_date, end_date)
	data := map[string][]mapper.MeasurementData{"measurements": items}
	return 200, data, http.Header{"Content-type": {"application/json"}}
}

func (item Measurement) Post(request *http.Request) (int, interface{}, http.Header) {
	err, measurement := mapper.CreateMeasurement(db, request.Body)
	if err != nil {
		log.Fatal(err)
		return 422, measurement, http.Header{"Content-type": {"application/json"}}

	} else {
		return 201, measurement, http.Header{"Content-type": {"application/json"}}
	}
}

type MeasurementDateRange struct{}

func (date_range MeasurementDateRange) Get(request *http.Request) (int, interface{}, http.Header) {
	err, data := mapper.GetDateRange(db)
	checkErr(err)
	return 200, data, http.Header{"Content-type": {"application/json"}}
}

func main() {
	initDB()
	flag.Parse()
	args := flag.Args()
	item := new(Measurement)
	date_range := new(MeasurementDateRange)
	api := sleepy.NewAPI()
	api.AddResource(item, "/measurements")
	api.AddResource(date_range, "/date-range")
	fmt.Println("Start API")

	chttp := api.Mux()
	chttp.Handle("/", http.FileServer(http.Dir("./public")))
	cors := cors.Default().Handler(chttp)

	http.ListenAndServe(args[1], cors)
}

func checkErr(err error) {
	if err != nil {
		fmt.Println(err)
		panic(err)
	}
}

func initDB() {
	flag.Parse()
	args := flag.Args()
	if len(args) < 2 {
		fmt.Println("no DB Login and Port defined! \n\t user:password 8080")
		os.Exit(1)
	}
	fmt.Println("Connect to DB")
	var err error
	db, err = sql.Open("mysql", args[0]+"@/greenhouse")
	checkErr(err)
	_, err = db.Exec(createsql)
	checkErr(err)
}

var db *sql.DB

// {"lux":384,"drewpoint":"9.94","humidity":"41.094","temp":"23.95","soil":"0.09","bar":"998.438"}
const createsql string = "CREATE TABLE IF NOT EXISTS measurements (id INT(11) NOT NULL AUTO_INCREMENT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, lux INT, drewpoint DECIMAL(8,2), humidity DECIMAL(8,3), temp DECIMAL(8,2), soil DECIMAL(8,2), bar DECIMAL(8,3), PRIMARY KEY (id)) ENGINE=InnoDB"
