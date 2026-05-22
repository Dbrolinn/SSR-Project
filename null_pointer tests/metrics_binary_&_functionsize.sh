#!/bin/bash
# for Binary sizes run these two
echo -n "compare binary sizes:" 
echo -e "\n"
ls -la vuln_O0 vuln_O2 vuln_flag vuln_fixed
echo -e "\n"
size vuln_O0 vuln_O2 vuln_flag vuln_fixed
echo -e "\n"
# to compare the size of the function run these two
echo -n "compare the sizes of the functions on vuln_O2 and vuln_flag"
echo -e "\n"
echo -e "vuln_O2"
echo -e "\n"
objdump -d vuln_O2   | awk '/^.*<process_request>:$/,/^$/' | wc -l
echo -e "\n "
echo -e "vuln_flag"
echo -e "\n"
objdump -d vuln_flag | awk '/^.*<process_request>:$/,/^$/' | wc -l
echo -e "\n"
# to confirm if the check is present or not run the the ones below, returns 0 implys it is removed, returns 1 then the check is present
echo -n "Seeing if null check exists 1=yes 0=no"
echo -e "\n"
echo -e "vuln_O2"
echo -e "\n"
objdump -d vuln_O2 | grep -c "test.*rdi"
echo -e "\n"
echo -e "vuln_flag"
echo -e "\n"
objdump -d vuln_flag | grep -c "test.*rdi" 
echo -e "\n"
echo -e "vuln_fixed"
echo -e "\n"
objdump -d vuln_fixed | grep -c "test.*rdi"
