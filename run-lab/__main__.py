#!/bin/bash
import os
from .run_case import *

def main():
    cwd = os.getcwd()
    test_cases = os.listdir(f"{cwd}/test-cases")
    print(f"Running {len(test_cases)} test cases {cwd}...")

    # error if empty
    if not test_cases:
        print("No test cases found")
        return
    for case_dir in test_cases:
        print(f"Running test case {case_dir}")
        case_path = f"{cwd}/test-cases/{case_dir}"
        run_case(case_path)
    print("All test cases completed")
    
if __name__ == "__main__":
    main()