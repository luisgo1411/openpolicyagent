package hello

default allow_ok = false
default allow_ng = false

allow_ok {
    "hello_world" == input.text
}

allow_ng {
    "hello_world" != input.text
}