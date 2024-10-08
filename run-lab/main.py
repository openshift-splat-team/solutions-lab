from .logs import *
from .run_case import *

def main():
    cwd = os.getcwd()
    test_cases = os.listdir(f"{cwd}/test-cases")
    info(f"Running {len(test_cases)} test cases {cwd}...")

    if not test_cases:
        info("No test cases found")
        return
    
    for case_dir in test_cases:
        info(f"Running test case {case_dir}")
        case_path = f"{cwd}/test-cases/{case_dir}"
        run_case(case_path)

    info("All test cases completed")