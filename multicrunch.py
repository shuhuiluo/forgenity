import subprocess
import time
from random import randint

NUM_PROCESSES = 6

# Define commands
commands = [f"forge test --mt testVanity --fuzz-seed {randint(0, 2 ** 32)}" for _ in range(NUM_PROCESSES)]

if __name__ == "__main__":
    # Build
    proc = subprocess.Popen("forge build", stdout=subprocess.PIPE)
    proc.wait()
    print(proc.communicate()[0].decode())

    # Start the processes
    processes = [subprocess.Popen(cmd, stdout=subprocess.PIPE) for cmd in commands]

    # Monitor the processes
    while True:
        for proc in processes:
            # Check if process has finished
            if proc.poll() is not None:
                # Get the output
                result = proc.communicate()[0].decode()
                print(result)

                # Write the result to file
                with open('vanity.txt', 'w') as file:
                    file.write(result)

                # Kill the rest
                for p in processes:
                    if p != proc:
                        p.kill()

                exit(0)
        time.sleep(0.1)  # sleep for 100 ms to reduce CPU usage
