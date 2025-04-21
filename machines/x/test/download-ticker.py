# !/usr/bin/env python3
""" usage: download-ticker.py [--daemon] [OUTDIR]
"""
import requests
import yaml
from time import sleep
from pathlib import Path
from datetime import datetime
from docopt import docopt

def fetch_data(outdir):
  try:
    print("Getting data")
    response = requests.get('https://blockchain.info/ticker')
    data = response.json()
    outfile = outdir / f'{datetime.now()}-ticker.yaml'
    with open(outfile, 'w') as f:
      print(f"Writing data to {outfile}")
      yaml.dump(data, f)
  except Exception as e:
    print(f"cannot fetch: {e}")
  finally:
    print("finished, sleeping")

def main():
  args = docopt(__doc__)
  outdir = Path(args["OUTDIR"] or ".")
  fetch_data(outdir)

  if args["--daemon"]:
    while sleep(61):
      fetch_data(outdir)
  else:
    print("not running as daemon")


if __name__ == '__main__':
  main()
