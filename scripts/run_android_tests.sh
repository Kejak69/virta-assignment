#!/bin/bash
appium --address 127.0.0.1 --port 4723 &

emulator -avd Pixel_5_API_31 -no-audio &

currentState=""
failCounter=0
startTimeout=180
until [[ "$currentState" =~ "1" ]]; do
    currentState=$(adb shell getprop sys.boot_completed | tr -d '\r')
    if [[ "$currentState" =~ "device not found" || "$currentState" =~ "device offline" || "$currentState" =~ "running" ]]; then
        ((failCounter += 1))
        echo "Waiting for emulator to start... $failCounter"
        echo "Boot Animation State: $currentState"

        if [[ ${failCounter} -gt ${startTimeout} ]]; then
            echo "Timeout of $startTimeout seconds reached; failed to start emulator"
            exit 1
        fi
    fi
    sleep 1
done

robot -N VirtaGlobal_Tests -d ..\\output\\ ..\\tests\\android_tests.robot

status=$(tail -16 ../output/output.xml | grep -o -P 'status=".{0,5}')
echo ${status}
if [[ "${status}" =~ 'status="FAIL"' ]]; then
    tail -6 ../output/output.xml | grep -o -P 'fail=".{0,3}'
fi