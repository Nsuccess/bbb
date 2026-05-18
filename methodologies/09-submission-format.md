# Submission Format Rules

## Mandatory: Raw HTTP Format for All Submissions

Every HackerOne/Intigriti/Bugcrowd submission MUST include requests in raw HTTP format. Do NOT submit raw JS console code.

## Conversion Template

### ❌ DON'T (JS Console)
```javascript
var x=new XMLHttpRequest();x.open('POST','https://target.com/graphql');x.withCredentials=true;x.setRequestHeader('Content-Type','application/json');x.setRequestHeader('X-CSRF-TOKEN','abc123');x.onreadystatechange=function(){if(x.readyState==4)console.log(x.status,x.responseText)};x.send(JSON.stringify({query:'mutation{...}'}));
```

### ✅ DO (Raw HTTP)
```
POST /graphql HTTP/1.1
Host: target.com
Content-Type: application/json
X-CSRF-TOKEN: abc123
Cookie: userToken=<jwt>

{"query":"mutation{...}"}
```

## Why
- Triagers copy-paste raw HTTP directly into Burp/their tools
- JS console output requires manual conversion for program teams
- Raw format gets ingested directly into ticketing systems
- Standard format triagers expect

## Script to Convert XHR → Raw HTTP

When testing via browser console, capture three things:
1. Request method + URL path
2. All request headers (from DevTools Network tab)
3. Request body
