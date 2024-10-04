#!/usr/bin/env python

## add proper main method and print the first argument.
import sys
import datetime
    
def run_case(case_dir):
    print(f"Running test case [{case_dir}]...")
    # get the last path segment as cluster_prefix
    cluster_prefix = case_dir.split("/")[-1]
    # get current hour and minute as a stamp
    now = datetime.datetime.now()
    stamp = now.strftime("%H%M")
    cluster_name = f"{cluster_prefix}-{stamp}"
    print(f"Cluster name: {cluster_name}")
    #TODO: create_logs_dir(case_dir, cluster_name)

def main():
    case_dir = sys.argv[1]
    run_case(case_dir)
    
if __name__ == "__main__":
    main()
