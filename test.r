REBOL
[
	Title: "Kyoto Tycoon API test"
	Date: 16-Feb-2011
	Version: 0.2.0
	File: %test.r
	Home: http://github.com/moechofe/KyoyoTycoon
	Author: {martin mauchauffée}
	Rights: {Copyleft}
	Tabs: 2
	History: [
		0.2.0 {Add SET/GET test. Add xt GET/SET test.}
		0.1.0 {Add Test::More style func.}
	]
	Language: 'English
	Library: [
		level: 'intermediate
		platform: 'all
		type: [tool]
		domain: [protocol database]
		tested-under: [core 2.7.6.3.1 Windows XP]
		tested-under: [core 2.7.8.4.2 Ubuntu]
		license: 'Copyleft
		see-also: [%kyoto.r] ]
]

do %kyoto.r

k: kyoto to-url first parse system/script/args none

tes: 0
oks: 0
kos: 0
ok: func [ ok ] [ print rejoin [ tes: add tes 1 "^-" either ok [oks: add oks 1 "ok"][kos: add kos 1 "not ok"] ] ]
is: func [ test expect ] [ ok equal? test expect ]

; test SET and GET
ok k/set "japan" "tokyo"
is k/get "japan" "tokyo"

; test XT with GET and SET
ok k/set/expire "china" "beijing" 1
is k/get/expire "china" xt "beijing"
ok number? xt
wait 1.2
is k/get/expire "china" xt none
ok none? xt

print reform [ "# ok:" oks "^/# not ok:" kos ]

halt

