# call, ret

## call

`call` will push the IP to stack and then jump to the target address

before `call`:

```
|XX| <==SP
```
after `call`:

```
|XX|
|IP| <==SP
```

## ret

`ret` will pop the **[SP]** to IP, and then jump to the address in IP

before `ret`:

```
|XX|
|IP| <==SP
```

after `ret`:
```
|XX| <==SP
```


## Test

```bash
make run -C src/instructions/call_ret
```
