package play
import future.keywords.if
import future.keywords.in

default allow = false

read_only_all := {
 "manager",
 "hr",
}

crud_method := {
 "GET",
 "UPDATE",
 "CREATE",
 "DELETE"
}

crud_user := {
 "hr"
}

allow if {
 input.method == "GET"
 input.path = ["payments", customer_id]
 input.user == customer_id
}

allow if {
 input.method == "GET"
    input.user in read_only_all
}

allow if {
    input.method in crud_method
    input.user in crud_user
}