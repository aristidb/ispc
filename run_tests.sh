#!/bin/zsh

surprises=0

echo Running correctness tests

for i in tests/*.ispc; do
    bc=${i%%ispc}bc
    ispc -O2 $i -woff -o $bc --emit-llvm --target=sse4
    if [[ $? != 0 ]]; then
        surprises=1
        echo Test $i FAILED ispc compile
        echo
    else
        ispc_test $bc
        if [[ $? != 0 ]]; then
            surprises=1
            echo Test $i FAILED ispc_test
            echo
        fi
#        cmp $bc tests_bitcode${bc##tests}
#        if [[ $? == 0 ]]; then
#            /bin/rm $bc
#        fi
    fi
    /bin/rm $bc
done

echo Running failing tests
for i in failing_tests/*.ispc; do
    (ispc -O2 $i -woff -o - --emit-llvm | ispc_test -) 2>/dev/null 1>/dev/null
    if [[ $? == 0 ]]; then
        surprises=1
        echo Test $i UNEXPECTEDLY PASSED
        echo
    fi
done

if [[ $surprises == 0 ]]; then
    echo No surprises.
fi

exit $surprises