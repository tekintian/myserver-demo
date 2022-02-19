// myhttp project myhttp.go
package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/index", IndexController)
	http.ListenAndServe(":8080", nil)
	log.Println("Server 8080 started!")
}

func IndexController(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "Hello world my mini server! \n This message from my mini server")
}
