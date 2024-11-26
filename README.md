
# How to Install and Use Open Policy Agent (OPA)

## Installation

### Download the Binary
Download the OPA binary using the following commands, and save it under the name `opa`.

#### Linux (64-bit)
```bash
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64
```

#### macOS (64-bit)
```bash
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_darwin_amd64
```

### Grant Execute Permission
After downloading the binary, grant execute permission:
```bash
chmod 755 opa
```

---

## Testing Installation
To verify the installation, navigate to the directory where `opa` is located and run:
```bash
./opa
```

If the binary is in your `PATH`, you can run it directly using:
```bash
opa
```

Expected output:
```bash
An open source project to policy-enable your service.

Usage:
opa [command]

Available Commands:
bench        Benchmark a Rego query
build        Build an OPA bundle
check        Check Rego source files
...
version      Print the version of OPA

Use "opa [command] --help" for more information about a command.
```

---

## Running OPA

### Create a Simple Policy
Let's create a simple policy to check if the input text matches `"hello_world"`.

**Policy File: `hello.rego`**
```rego
package hello

default allow_ok = false
default allow_ng = false

allow_ok {
    "hello_world" == input.text
}

allow_ng {
    "hello_world" != input.text
}
```

**Input File: `input.json`**
```json
{
  "text": "hello_world"
}
```

Run the policy using OPA:
```bash
opa eval --data hello.rego --input input.json "data.hello.allow_ok"
```

Expected output:
```json
{
  "result": [
    {
      "expressions": [
        {
          "value": true,
          "text": "data.hello.allow_ok",
          "location": {
            "row": 1,
            "col": 1
          }
        }
      ]
    }
  ]
}
```

---

## Deployment

OPA offers multiple deployment options:
1. As a standalone binary on a local machine or containerized environment using Docker.
2. Integrated with Kubernetes as a sidecar proxy or dedicated server.
3. Embedded within application code for fine-grained policy enforcement.
4. As a centralized policy engine for multiple applications.

Learn more about deployments [here](https://www.openpolicyagent.org/docs/latest/deployments/).

---

## Example Use Case: Salary Service

### Scenario
- **Employee**: Can view their own salary.
- **Manager**: Can view salaries of their downline employees but cannot modify them.
- **HR**: Has full access (view, create, update, delete) to all salary records.

### Policy File: `salary_policy.rego`
```rego
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
    input.user == input.path[1]
}

allow if {
    input.method == "GET"
    input.user in read_only_all
}

allow if {
    input.method in crud_method
    input.user in crud_user
}
```

### Test Cases
#### Employee Viewing Their Own Salary
Input:
```json
{
    "method": "GET",
    "path": ["payments", "bob"],
    "user": "bob"
}
```

Command:
```bash
opa eval --data salary_policy.rego --input input.json "data.play.allow"
```

Expected Output:
```json
{
  "result": [
    {
      "expressions": [
        {
          "value": true
        }
      ]
    }
  ]
}
```

Repeat similar steps to validate other scenarios like managers and HR access rights.

---

## Benefits of Using OPA

- Centralized policy enforcement across all applications and infrastructure.
- Simplifies application logic by separating policy decisions.
- Enforces consistent security and authorization policies.

Try OPA's [Rego Playground](https://play.openpolicyagent.org/) to experiment with policies interactively!
