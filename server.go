//---------------------------------------------------------------------------------------------------------------------
// Filename: server.go
// Description: Contains all relevant functions to create the web server and filter api routes
// Authors: Alex Creencia
//          Xavier Kidston
//---------------------------------------------------------------------------------------------------------------------


package main

import (
	"fmt"
	"net/http"
	"os"
	"github.com/gorilla/mux"

)

type handlers struct{
	database string //change it to database pointer later on
}


func (h *handlers) getParkingLotHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Entered getParkingLotHandler")
}

func (h *handlers) parkingDataHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Entered parkingDataHandler")
}

func (h *handlers) updateParkingStallHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Entered updateParkingStallHandler")
}


func NewRouter(db string) http.Handler {
	baseHandler := &handlers{
		database: db,
	}
	router := mux.NewRouter()
	router.PathPrefix("/api/v1/parking-lot/{place-name}/{lot-ID}").Methods(http.MethodGet).HandlerFunc(baseHandler.getParkingLotHandler)
	router.PathPrefix("/api/v1/parking-lot/{place-name}").Methods(http.MethodGet).HandlerFunc(baseHandler.parkingDataHandler)
	router.PathPrefix("/api/v1/stall-status/{place-name}/{stall-ID}").Methods(http.MethodPut).HandlerFunc(baseHandler.updateParkingStallHandler)
	return router
}

func main() {
	router := NewRouter("testing")
	if err := http.ListenAndServe(":42069", router); err != nil {
		fmt.Fprintf(os.Stderr, "cannot create server: %v\n", err)
	}
	
}
