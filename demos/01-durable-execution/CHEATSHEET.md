# Demo Cheatsheet

## Setup
```
restate deployments register http://localhost:9080
```

## Reset
```
restate invocations cancel Greeter --kill --yes
restate invocations purge Greeter --yes
```

## Trigger a Failure
```
touch FAIL_DEMO
http POST localhost:8080/Greeter/greet/send name=DevNexus
http localhost:8080/restate/invocation/INVOCATION_ID/output
lsof -ti :9080 | xargs kill
```

## Fix the Failure
```
rm FAIL_DEMO
npm run dev
http localhost:8080/restate/invocation/INVOCATION_ID/output
```

## Show Replay Logs
```
cat demo-log.txt
```
