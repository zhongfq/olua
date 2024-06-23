package main

import (
	"flag"
	"io"
	"net/http"
	"os"
)

var url = flag.String("l", "", "zip url")
var file = flag.String("o", "", "download file")

func main() {
	flag.Parse()
    resp, err := http.Get(*url)
    if err != nil {
        panic(err)
    }
    defer resp.Body.Close()

    out, err := os.Create(*file)
    if err != nil {
        panic(err)
    }
    defer out.Close()

    _, err = io.Copy(out, resp.Body)
    if err != nil {
		os.Remove(*file)
        panic(err)
    }
}