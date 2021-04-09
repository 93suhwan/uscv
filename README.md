# USCV : A Unified Smart Contract Validator

USCV is a unified analysis platform that leverages the latest Ethereum smart contract analyzers to detect various security vulnerabilities and help the users to lint Solidity code.


USCV currently supports the following tools.

## Security Tools
- Manticore
- Mythril
- Oyente
- Securify
- Slither
- SmartCheck
- Solhint
- VeriSmart

## Testing Tools and Linters
- Echidna
- Ethlint
- Sol-profiler

## Requirements
- Unix-based system (Ubuntu 16.04 or above)
- Docker 18.09 or above
- Python 3.5 or above

## Installation:
```bash
$ git clone https://github.com/93suhwan/uscv.git
$ cd uscv
$ ./createContainers.sh
```

We recommend to run as the root user. (If you import files from the Docker containers to host, they are by default under the root privilege.)

## Execution:
```bash
./execution.sh [OPTIONS]
               -f <string>  Used to specify the name of a source file.
               -d <string>  Used to specify the name of a directory (recursively).
               -t <string>  Used to specify the tool.
                            echidna | ethlint | manticore | mythril | oyente | securify
                            slither | smartcheck | solhint | sol-profiler | verismart
                            Security | Testing | All | Name of being added countermeasure.
               -v <string>  Used to specify a type of vulnerability.
                            AC | DOS | FR | IO | RE | TD | UC
               -r           Used to apply only the effective tool set (proposed)
               -l <int>     Used to specify a timeout value.
               -o "string"  Used to specify the options that the tool uniquely supports.
```

## Examples 
1. To detect the vulnerabilities in the ./code/test.sol file using all the Security tools:
```bash
$ sudo ./execution.sh -f ./code/test.sol -t Security
```

2. To detect the IO vulnerability in all *.sol files in ./code:
```bash
$ sudo ./execution.sh -d ./code -v IO
```

## Result
The result is saved as ./result/{input_file_PATH}/{sol_filename}/{tool_name}.txt or ./result/{input_dir_PATH}/{sol_filename}/{tool_name}.txt and is synthesized in the comparison.txt file.


```bash
$ cat result/code/comparison.txt
                AC      DOS     FR      IO      RE      TD      UC
Manticore       X       -       X       O       X       X       X
Mythril         X       X       -       O       X       X       X
Oyente          X       -       X       O       X       X       -
Securify        X       -       X       -       X       X       X
Slither         X       -       -       -       X       X       X
SmartCheck      X       X       -       X       -       X       X
Solhint         -       -       -       -       X       X       -
VeriSmart       -       -       -       O       -       -       -
./result/code/test/test.sol
```
