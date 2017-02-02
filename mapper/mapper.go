package mapper

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"io"
	"time"
)

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

func GetAll(db *sql.DB, start_date string, end_date string) (items []MeasurementData) {
	query := "SELECT * FROM measurements"
	var wheres []string

	if len(start_date) > 0 {
		date, _ := time.Parse(time.RFC3339, start_date)
		wheres = append(wheres, fmt.Sprint("created_at >= '", date.Format("2006-01-02 15:04:05"), "'"))
	}
	if len(end_date) > 0 {
		date, _ := time.Parse(time.RFC3339, end_date)
		date = date.Add(24 * time.Hour)
		date = date.Add(24 * time.Minute)
		date = date.Add(24 * time.Second)
		wheres = append(wheres, fmt.Sprint("created_at <= '", date.Format("2006-01-02 15:04:05"), "'"))
	}
	fmt.Println(wheres)
	rows, err := db.Query(query)
	checkErr(err)

	items = []MeasurementData{}
	for rows.Next() {
		measurement := new(MeasurementData)
		err = rows.Scan(&measurement.ID, &measurement.CreatedAt, &measurement.Lux, &measurement.Drewpoint, &measurement.Humidity, &measurement.Temp, &measurement.Soil, &measurement.Bar)
		checkErr(err)
		items = append(items, *measurement)
	}
	return
}

// Create a Measurement Object
// {"lux":384,"drewpoint":"9.94","humidity":"41.094","temp":"23.95","soil":"0.09","bar":"998.438"}
func CreateMeasurement(db *sql.DB, json_data io.Reader) (err error, measurement MeasurementData) {
	measurement = decodeMeasurementFromJson(json_data)
	fmt.Println(measurement)

	// Prepare statement for inserting data
	stmt, err := db.Prepare("INSERT INTO measurements (lux, drewpoint, humidity, temp, soil, bar) VALUES( ?, ?, ?, ?, ?, ? )")
	checkErr(err)
	// Close the statement when we leave main() / the program terminates
	defer stmt.Close()

	_, err = stmt.Query(measurement.Lux, measurement.Drewpoint, measurement.Humidity, measurement.Temp, measurement.Soil, measurement.Bar)
	return
}

func GetDateRange(db *sql.DB) (err error, data map[string]string) {
	data = make(map[string]string)
	var min *string
	var max *string
	rows, err := db.Query("SELECT min(created_at) FROM measurements")
	checkErr(err)
	for rows.Next() {
		err = rows.Scan(&min)
		checkErr(err)
	}
	rows, err = db.Query("SELECT max(created_at) FROM measurements")
	checkErr(err)
	for rows.Next() {
		err = rows.Scan(&max)
		checkErr(err)
	}
	data["min"] = *min
	data["max"] = *max
	return
}

func decodeMeasurementFromJson(json_data io.Reader) (measurement_data MeasurementData) {
	decoder := json.NewDecoder(json_data)
	err := decoder.Decode(&measurement_data)
	fmt.Println(measurement_data)

	if err != nil && err.Error() != "EOF" {
		fmt.Println(err)
		panic(err)
	}
	return
}

// Check errors
func checkErr(err error) {
	if err != nil {
		fmt.Println(err)
		panic(err)
	}
}
