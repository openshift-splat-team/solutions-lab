from .logs import *
from .utils import *
from .run_case import *

def main():
    info("Starting solutions-lab")
    cwd = os.getcwd()
    cases_dir = f"{cwd}/test-cases"
    test_cases = os.listdir(cases_dir)
    debug(f"{len(test_cases)} test cases found")
    if not test_cases:
        warn("No test cases found in [{test_cases}]")
        # TODO: Replace with enum?
        sys_exit(1)
    
    for case_dir in test_cases:
        info(f"Found test case {case_dir}")
        case_path = f"{cases_dir}/{case_dir}"
        run_case(case_path)

    info("All test cases completed")