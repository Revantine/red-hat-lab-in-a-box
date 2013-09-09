#!/bin/bash
(
exit 0
) || echo "Failed" |tee output.txt
echo "return $?"
