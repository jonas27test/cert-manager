// package main

// import (
// 	"crypto/rand"
// 	"crypto/tls"
// 	"crypto/x509"
// 	"fmt"
// 	"io/ioutil"
// 	"log"
// 	"net"
// 	"net/http"
// )

// // func main() {
// // 	log.SetFlags(log.Lshortfile)
// // 	log.Println("hello world from webhook service")
// // 	http.HandleFunc("/", root)
// // 	http.HandleFunc("/mutate", mutate)
// // 	// http.ListenAndServe(":8080", nil)
// // 	// log.Println(http.ListenAndServeTLS(":8080", "./certs/arc/server-tls.crt", "./certs/arc/server-tls.key", nil))
// // 	// log.Println(http.ListenAndServeTLS(":8080", "./certs/demo/webhook.csr", "./certs/demo/webhook.key", nil))
// // 	log.Println(http.ListenAndServeTLS(":8080", "./certs/client-auth/certs/server.pem", "./certs/client-auth/certs/server.key", nil))
// // 	// log.Println(http.ListenAndServeTLS(":8080", "./certs/server-cert/cer.pem", "./certs/server-cert/key.pem", nil))
// // 	// log.Println(http.ListenAndServeTLS(":8080", "./certs/server.crt", "./certs/server-key.pem", nil))
// // }

// func main() {
// 	log.SetFlags(log.Lshortfile)

// 	cert, err := tls.LoadX509KeyPair("./certs/client-auth/certs/server.pem", "./certs/client-auth/certs/server.key")
// 	if err != nil {
// 		log.Fatalf("server: loadkeys: %s", err)

// 	}
// 	certpool := x509.NewCertPool()
// 	pem, err := ioutil.ReadFile("./certs/client-auth/certs/ca.pem")
// 	if err != nil {
// 		log.Fatalf("Failed to read client certificate authority: %v", err)
// 	}
// 	if !certpool.AppendCertsFromPEM(pem) {
// 		log.Fatalf("Can't parse client certificate authority")
// 	}

// 	config := tls.Config{
// 		Certificates: []tls.Certificate{cert},
// 		ClientAuth:   tls.RequireAndVerifyClientCert,
// 		ClientCAs:    certpool,
// 	}
// 	config.Rand = rand.Reader
// 	service := "0.0.0.0:8080"
// 	listener, err := tls.Listen("tcp", service, &config)
// 	if err != nil {
// 		log.Fatalf("server: listen: %s", err)
// 	}
// 	log.Print("server: listening")
// 	for {
// 		conn, err := listener.Accept()
// 		if err != nil {
// 			log.Printf("server: accept: %s", err)
// 			break
// 		}
// 		log.Printf("server: accepted from %s", conn.RemoteAddr())
// 		go handleClient(conn)
// 	}
// }

// func handleClient(conn net.Conn) {
// 	defer conn.Close()
// 	tlscon, ok := conn.(*tls.Conn)
// 	if ok {
// 		log.Print("server: conn: type assert to TLS succeedded")
// 		err := tlscon.Handshake()
// 		if err != nil {
// 			log.Fatalf("server: handshake failed: %s", err)
// 		} else {
// 			log.Print("server: conn: Handshake completed")
// 		}
// 		state := tlscon.ConnectionState()
// 		log.Println("Server: client public key is:")
// 		for _, v := range state.PeerCertificates {
// 			log.Print(x509.MarshalPKIXPublicKey(v.PublicKey))
// 		}
// 		buf := make([]byte, 512)
// 		for {
// 			log.Print("server: conn: waiting")
// 			n, err := conn.Read(buf)
// 			if err != nil {
// 				if err != nil {
// 					log.Printf("server: conn: read: %s", err)
// 				}
// 				break

// 			}
// 			log.Printf("server: conn: echo %q\n", string(buf[:n]))
// 			n, err = conn.Write(buf[:n])
// 			log.Printf("server: conn: wrote %d bytes", n)
// 			if err != nil {
// 				log.Printf("server: write: %s", err)
// 				break
// 			}
// 		}
// 	}
// 	log.Println("server: conn: closed")
// }

// func mutate(w http.ResponseWriter, r *http.Request) {
// 	log.Println("mutate")
// 	fmt.Fprint(w, "mutate")
// 	s := string(getBody(r))
// 	log.Println(s)
// }

// func root(w http.ResponseWriter, r *http.Request) {
// 	log.Println("root")
// 	fmt.Fprint(w, "root")
// 	s := string(getBody(r))
// 	log.Println(s)
// }

// func getBody(r *http.Request) []byte {
// 	bodyBytes, err := ioutil.ReadAll(r.Body)
// 	if err != nil {
// 		log.Println(err)
// 	}
// 	return bodyBytes
// }

// func enableCors(w *http.ResponseWriter) {
// 	(*w).Header().Set("Access-Control-Allow-Origin", "*")
// 	(*w).Header().Set("Content-Type", "application/json")
// 	(*w).Header().Set("Access-Control-Allow-Credentials", "true")
// 	(*w).Header().Set("Access-Control-Allow-Methods", "GET,HEAD,OPTIONS,POST,PUT")
// 	(*w).Header().Set("Access-Control-Allow-Headers", "Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers")
// }

package main

import (
	"crypto/tls"
	"fmt"
	"html"
	"io/ioutil"
	"log"
	"net/http"
	"time"

	m "github.com/alex-leonhardt/k8s-mutate-webhook/pkg/mutate"
)

func handleRoot(w http.ResponseWriter, r *http.Request) {
	log.Println("root")
	fmt.Fprintf(w, "hello %q", html.EscapeString(r.URL.Path))
}

func handleMutate(w http.ResponseWriter, r *http.Request) {
	log.Println("dooone")
	// read the body / request
	body, err := ioutil.ReadAll(r.Body)
	defer r.Body.Close()

	if err != nil {
		sendError(err, w)
		return
	}

	// mutate the request
	mutated, err := m.Mutate(body, true)
	if err != nil {
		sendError(err, w)
		return
	}

	// and write it back
	w.WriteHeader(http.StatusOK)
	w.Write(mutated)
}

func sendError(err error, w http.ResponseWriter) {
	log.Println(err)
	w.WriteHeader(http.StatusInternalServerError)
	fmt.Fprintf(w, "%s", err)
}

func main() {
	log.SetFlags(log.Lshortfile)
	log.Println("Starting server ...")

	mux := http.NewServeMux()

	mux.HandleFunc("/", handleRoot)
	mux.HandleFunc("/mutate", handleMutate)

	s := &http.Server{
		TLSConfig:      &tls.Config{InsecureSkipVerify: true},
		Addr:           ":8080",
		Handler:        mux,
		ReadTimeout:    10 * time.Second,
		WriteTimeout:   10 * time.Second,
		MaxHeaderBytes: 1 << 20, // 1048576
	}

	log.Fatal(s.ListenAndServeTLS("/certswebhook/tls.crt", "/certswebhook/tls.key"))
}
