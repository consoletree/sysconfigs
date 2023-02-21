#!/usr/bin/bash

# just added a comment
# Getting the from and to destinations
getStops() {
	
	destination=("From: " "To: ")

	for i in 0 1; do
		read -p "${destination[$i]}" now

		url="https://ae72qusyyn-dsn.algolia.net/1/indexes/TRIPPOINT_PROD_TR/query?"
		url+="x-algolia-agent=Algolia%20for%20JavaScript%20(3.33.0)%3B%20Browser&"
		url+="x-algolia-application-id=AE72QUSYYN&x-algolia-api-key=55edc99b34a5f4dbbc60a37b727b2c98"

		destination[$i]=$(curl -s "$url" \
			-X POST --compressed \
			-H 'Sec-Fetch-Mode: cors' \
			-H 'Sec-Fetch-Dest: empty' \
			-H 'Connection: keep-alive' \
			-H 'Accept: application/json' \
			-H 'Sec-Fetch-Site: cross-site' \
			-H 'Accept-Language: en-US,en;q=0.5' \
			-H 'Origin: https://whitelabel.triplinx.ca' \
			-H 'Referer: https://whitelabel.triplinx.ca/' \
			-H 'content-type: application/x-www-form-urlencoded' \
			--data-raw $'{"params":"query='"$now"'&hitsPerPage=1000&typoTolerance=true"}' \
			-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:94.0) Gecko/20100101 Firefox/94.0' \
			| jq .hits[].NAME | tr -d '"' | fzf | sed 's/ /+/g')
	done
}

# parsing to get the transport details
getInfo() {
	
	# most probably referer is no needed but still
	referer="Referer: https://whitelabel.triplinx.ca/en/trip-planner/4/TripPlanner/index?" # base
	referer+="KeywordDep=ELLESMERE%20RD%20AT%20MEADOWVALE%20RD%2C%20TORONTO&PointDep=2684_4&" # from 
	referer+="KeywordArr=ELLESMERE%20RD%20AT%20KENNEDY%20RD%2C%20TORONTO&PointArr=1489_4&" # to
	referer+="Date=11%2F17%2F2021&TypeDate=68&Hour=2&Minute=30&Meridian=PM&DurationVia=30&" # time
	referer+="Algorithm=Fastest&TypeTrip=PlanTrip&ListModes=Bus%7CMetro%7CTram%7CTrain%7CBoat&IgnoreDisruptions=False&" # advanced
	referer+="ListPartners=21%7C9%7C7%7C11%7C2%7C22%7C8%7C5%7C10%7C20%7C19%7C6%7C15%7C18%7C16%7C3%7C14%7C17%7C4&" # partner thing
	referer+="WalkDistance=2000&WalkSpeed=5&CarDistance=25&CarLeave=2&BikeDistance=10&Accessibility=0&" # some distance parameters
	referer+="IsoBefore=True&Submit=False&ExpandCriteria=0&_=1637177264551" # again no idea
	
	# fuck full of url encodings
	dataRaw="request%5BKeywordDep%5D=ELLESMERE+RD+AT+MEADOWVALE+RD%2C+TORONTO&" # from
	dataRaw+="request%5BNumDep%5D=&request%5BPointDep%5D=2684_4&request%5BLatDep%5D=&request%5BLngDep%5D=&" # n.i, maybe something related to lon-lan of loction
	dataRaw+="request%5BKeywordArr%5D=ELLESMERE+RD+AT+KENNEDY+RD%2C+TORONTO&" # to
	dataRaw+="request%5BNumArr%5D=&request%5BPointArr%5D=1489_4&request%5BLatArr%5D=&request%5BLngArr%5D=&" # n.i, maybe something related to lon-lan of loction
	dataRaw+="request%5BDate%5D=11%2F17%2F2021&request%5BTypeDate%5D=68&request%5BHour%5D=2&request%5BMinute%5D=30&request%5BMeridian%5D=PM&" # date & time
	dataRaw+="request%5BKeywordVia%5D=&request%5BNumVia%5D=&request%5BPointVia%5D=&request%5BDurationVia%5D=30&request%5BLatVia%5D=&request%5BLngVia%5D=&" # n.i
	dataRaw+="request%5BAlgorithm%5D=Fastest&request%5BTypeTrip%5D=PlanTrip&request%5BModes%5D%5B%5D=Bus&" # advanced
	dataRaw+="request%5BModes%5D%5B%5D=Metro&request%5BModes%5D%5B%5D=Tram&request%5BModes%5D%5B%5D=Train&" # advanced
	dataRaw+="request%5BModes%5D%5B%5D=Boat&request%5BListModes%5D=Bus%7CMetro%7CTram%7CTrain%7CBoat&request%5BIgnoreDisruptions%5D=false&" # advanced
	dataRaw+="request%5BPartners%5D%5B%5D=21&request%5BPartners%5D%5B%5D=9&request%5BPartners%5D%5B%5D=7&"  # partner thing 
	dataRaw+="request%5BPartners%5D%5B%5D=11&request%5BPartners%5D%5B%5D=2&request%5BPartners%5D%5B%5D=22&" # partner thing
	dataRaw+="request%5BPartners%5D%5B%5D=8&request%5BPartners%5D%5B%5D=5&request%5BPartners%5D%5B%5D=10&"  # partner thing
	dataRaw+="request%5BPartners%5D%5B%5D=20&request%5BPartners%5D%5B%5D=19&request%5BPartners%5D%5B%5D=6&" # partner thing
	dataRaw+="request%5BPartners%5D%5B%5D=15&request%5BPartners%5D%5B%5D=18&request%5BPartners%5D%5B%5D=16&" # partner thing
	dataRaw+="request%5BPartners%5D%5B%5D=3&request%5BPartners%5D%5B%5D=14&request%5BPartners%5D%5B%5D=17&"
	dataRaw+="request%5BPartners%5D%5B%5D=4&" # partner thing
	dataRaw+="request%5BListPartners%5D=21%7C9%7C7%7C11%7C2%7C22%7C8%7C5%7C10%7C20%7C19%7C6%7C15%7C18%7C16%7C3%7C14%7C17%7C4&" # partner thing
	dataRaw+="request%5BWalkDistance%5D=2000&request%5BWalkSpeed%5D=5&request%5BCarDistance%5D=25&request%5BCarLeave%5D=2&" # advanced
	dataRaw+="request%5BBikeDistance%5D=10&request%5BBikeLeave%5D=&request%5BBikeSpeed%5D=&request%5BBikeSecure%5D=&" # advanced
	dataRaw+="request%5BBikeOnBoard%5D=&request%5BAvoidStop%5D=&request%5BAccessibility%5D=0&request%5BIsoBefore%5D=true&" # advanced
	dataRaw+="request%5BPointPark%5D=&request%5BPointInt%5D=&request%5BCodeRequest%5D=&request%5BOtherParameters%5D%5B_%5D=1637177264551&" # advanced
	dataRaw+="request%5BSubmit%5D=false&request%5BExpandCriteria%5D=0&requestKey=c1814a41-6747-4256-9aae-3d2697ef557c&detailTypeTrip=&detailTripNum=" # advanced

	curl 'https://whitelabel.triplinx.ca/en/TripPlanner/getresult' \
		-H "$referer" \
		-H 'Accept: */*' \
		--data-raw "$dataRaw" \
		-X POST --compressed \
		-H 'Sec-Fetch-Mode: cors' \
		-H 'Sec-Fetch-Dest: empty' \
		-H 'Connection: keep-alive' \
		-H 'Sec-Fetch-Site: same-origin' \
		-H 'Accept-Language: en-US,en;q=0.5' \
		-H 'X-Requested-With: XMLHttpRequest' \
		-H 'Origin: https://whitelabel.triplinx.ca' \
		-H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
		-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:94.0) Gecko/20100101 Firefox/94.0' \
		-H 'Cookie: ASP.NET_SessionId=m3bxkg0giwgeuu5kpgazg0up; language=en; cityWay.cookies.map.rememberLayer=layer-here-route' 
}

getStops
