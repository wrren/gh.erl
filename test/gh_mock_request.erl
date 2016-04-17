-module( gh_mock_request ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-export( [request/7] ).

request( _BaseUrl, _Endpoint, _Params, _Method, _Body, _ContentType, _Auth ) -> { ok, [] }.
