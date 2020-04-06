package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

func main() {
	log.SetFlags(log.Lshortfile)
	log.Println("hello world from webhook service")
	http.HandleFunc("/mutate", mutate)
	// http.ListenAndServe(":8080", nil)
	log.Println(http.ListenAndServeTLS(":8080", "./certs/server.crt", "./certs/server-key.pem", nil))
}

func mutate(w http.ResponseWriter, r *http.Request) {
	log.Println("mutate")
	fmt.Fprint(w, "mutate")
	s := string(getBody(r))
	log.Println(s)
}

func getBody(r *http.Request) []byte {
	bodyBytes, err := ioutil.ReadAll(r.Body)
	if err != nil {
		log.Println(err)
	}
	return bodyBytes
}

func enableCors(w *http.ResponseWriter) {
	(*w).Header().Set("Access-Control-Allow-Origin", "*")
	(*w).Header().Set("Content-Type", "application/json")
	(*w).Header().Set("Access-Control-Allow-Credentials", "true")
	(*w).Header().Set("Access-Control-Allow-Methods", "GET,HEAD,OPTIONS,POST,PUT")
	(*w).Header().Set("Access-Control-Allow-Headers", "Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers")
}
