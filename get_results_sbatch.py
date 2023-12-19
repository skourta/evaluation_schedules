import argparse
import json
from pathlib import Path


def sort_by_name_and_size(program):
    SIZES = {"MINI": 0, "SMALL": 1, "MEDIUM": 2, "LARGE": 3, "XLARGE": 4}
    name = program.split("_")[1]
    size = program.split("_")[-1]
    return name, SIZES[size]


parser = argparse.ArgumentParser()

parser.add_argument("schedules", default="djamel_schedules")

# add flag to get unoptimized times
parser.add_argument(
    "--unoptimized",
    action="store_true",
    help="get the unoptimized execution times",
)


if __name__ == "__main__":
    args = parser.parse_args()

    # load the explored_programs.json from the schedules folder
    with open(f"{args.schedules}/explored_programs.json", "r") as f:
        explored_programs = json.load(f)
    for program in explored_programs:
        explored_programs[program]["original_min"] = None
        explored_programs[program]["original_all"] = None

        schedule_path = next(Path(args.schedules).rglob(f"**/{program}.txt"), None)

        if schedule_path is None:
            continue

        # read the execution times from the schedules folder
        with open(schedule_path, "r") as f:
            results = f.read()
            results = [float(x) for x in results.split()]
            if results:
                explored_programs[program]["schedules_min"] = min(results)
                explored_programs[program]["schedules_all"] = results

        # read the execution times from the unoptimized folder
        if args.unoptimized:
            unoptimized_path = next(
                Path(args.schedules).rglob(f"**/{program}_unoptimized.txt"), None
            )
            if unoptimized_path is None:
                continue
            with open(unoptimized_path, "r") as f:
                results = f.read()
                results = [float(x) for x in results.split()]
                if results:
                    explored_programs[program]["original_min"] = min(results)
                    explored_programs[program]["original_all"] = results

    print("explored: ", len(explored_programs))
    # save dict as json and csv file
    with open(f"{args.schedules}/results/{args.schedules}_results.json", "w") as f:
        json.dump(explored_programs, f, indent=4)

    with open(f"{args.schedules}/results/{args.schedules}_results.csv", "w") as f:
        f.write(
            "program,schedule,original_min,schedules_min,speedup,speedup_predicted_model\n"
        )
        sorted_names = list(explored_programs.keys())
        sorted_names.sort(key=sort_by_name_and_size)
        # print(len(sorted_names))
        for program in sorted_names:
            if not "schedules_min" in explored_programs[program]:
                continue
            speedup = 1
            if explored_programs[program]["schedule"]:
                speedup = (
                    explored_programs[program]["original_min"]
                    / explored_programs[program]["schedules_min"]
                    if explored_programs[program]["original_min"]
                    else None
                )
            f.write(
                f"{program},{explored_programs[program]['schedule'].replace(',',';')},{explored_programs[program]['original_min']},{explored_programs[program]['schedules_min']},{speedup},{explored_programs[program]['speedup_model']}\n"
            )

        # filter explored_programs to only contain programs with schedules_min defined
        explored_programs_filtered = {
            program: explored_programs[program]
            for program in explored_programs
            if "schedules_min" in explored_programs[program]
        }
        print(
            [
                program
                for program in explored_programs
                if "schedules_min" not in explored_programs[program]
            ]
        )

    print("done!")
