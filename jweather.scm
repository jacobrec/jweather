#!/usr/local/bin/guile
!#
(define-module (jweather jweather)
  #:use-module (web client)
  #:use-module (web response)
  #:use-module (rnrs bytevectors)
  #:use-module (json)
  #:use-module (jlib print)
  #:use-module (jlib lists))

(load "jweather-secrets")
; secrets should define these variables
; (define api-key "00000000000000000000000000000000")
; (define filepath "/home/user/.data-file-for-jweather")
; (define city-id "0000000")
; (define url (string-append "http://api.openweathermap.org/data/2.5/weather?id=" city-id "&APPID=" api-key))

(define (get-data)
  (define-values (res data) (http-get url))
  (json-string->scm (utf8->string data)))

(define (data-weather data)
  (assoc-get "id" (vector-ref (assoc-get "weather" data) 0)))

(define (data-temp data)
  (inexact->exact (* 100 (assoc-get '("main" "temp") data))))

(define (should-sync)
  (with-input-from-file filepath
    (lambda ()
      (> (current-time)
         (+ (read) (* 5 60))))))

(define (sync)
  (define data (get-data))
  (with-output-to-file filepath (lambda ()
                                  (println (current-time))
                                  (println (data-weather data))
                                  (println (data-temp data)))))
(define (inrange x low up)
  (and (>= x low) (< x up)))
(define (print)
  (with-input-from-file filepath
    (lambda ()
      (define time (read))
      (define weather-code (read))
      (define temp (read))
      (define in (lambda (low high) (inrange weather-code low high)))
      (define sym
        (cond
         ((in 200 300) " ⛈️ ") ; Stormy
         ((in 300 600) " 🌧️ ") ; Rainy
         ((in 600 700) " 🌨️ ") ; Snowy
         ((in 700 800) " ☁️ ") ; Fog, smoke, ash (Atmosphere)
         ((in 800 802) " ☀️ ") ; Sunny, few clouds
         ((in 802 804) " ⛅ ") ; scattered clouds, broken clouds
         ((in 804 805) " ☁️ ") ; Overcast
         (else " # ")))
      (display sym)
      (format #t "~1,2f" (- (/ temp 100) 273.15))
      (println "°C"))))

(define is-sync
  (or
    (member "--sync" (command-line))
    (member "-s" (command-line))
    (member "sync" (command-line))))
(cond
 ((and is-sync (should-sync)) (sync))
 (else (print)))
