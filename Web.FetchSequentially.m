/*
//Sequentially scrape a given list of URLs with a given minimum delay between fetches
//Usage:

let
    BaseUrl = "http://example.com/?p=",
    Pages = List.Numbers(1, 5),
    Urls = List.Transform(Pages, each BaseUrl & Number.ToText(_))
in
    Web_FetchSequentially(Urls)

//Result: [a list of decoded contents for each of the input URLs]
*/

let Web.FetchSequentially = (
	Urls as list,
	optional Delay as number,		//in seconds, default 1
	optional Encoding as number,	//https://msdn.microsoft.com/en-us/library/windows/desktop/dd317756(v=vs.85).aspx
	optional Options				//see options below
) =>

let
    Delay = if (Delay<>null) then Delay else 1,
    Encoding = if (Encoding<>null) then Encoding else TextEncoding.Utf8,
    Options = if (Options<>null) then Options else [
		//ApiKeyName = "",
		//Content = "",
		Query = [],
		Headers = []
	],
    Count = List.Count(Urls)
in

List.Skip(
	List.Generate(
		() => [
			i = 0,
			Page = null
		],
		each [i] <= Count,
		each let
			Url = Urls{[i]},
			GetPage = (uri as text) => Text.FromBinary(Web.Contents(uri, Options), Encoding)
		in [
			i = [i] + 1,
			Page = Function.InvokeAfter(()=>GetPage(Url), #duration(0,0,0,Delay))
		],
		each [Page]
	)
)

in
    Web.FetchSequentially
