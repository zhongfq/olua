package main

import (
	"archive/zip"
	"flag"
	"io"
	"log"
	"os"
	"strings"
)

var zipFile = flag.String("f", "", "zip file path")
var dest = flag.String("o", "", "output directory")

func main() {
	flag.Parse()
	reader, err := zip.OpenReader(*zipFile)
	if err != nil {
		log.Fatal(err)
	}
	defer reader.Close()
	for _, file := range reader.File {
		rc, err := file.Open()
		if err != nil {
			log.Fatal(err)
		}
		defer rc.Close()
		filename := *dest + "/" + file.Name
		print("unzip: " + filename + "\n")
		err = os.MkdirAll(getDir(filename), 0755)
		if err != nil {
			log.Fatal(err)
		}
		w, err := os.Create(filename)
		if err == nil {
			defer w.Close()
			_, err = io.Copy(w, rc)
			if err != nil {
				log.Fatal(err)
			}
			w.Close()
			rc.Close()
		}
	}
}

func getDir(path string) string {
	return subString(path, 0, strings.LastIndex(path, "/"))
}

func subString(str string, start, end int) string {
	rs := []rune(str)
	length := len(rs)

	if start < 0 || start > length {
		panic("start is wrong")
	}

	if end < start || end > length {
		panic("end is wrong")
	}

	return string(rs[start:end])
}
