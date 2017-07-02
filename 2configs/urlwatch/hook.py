import logging
logging.basicConfig(level=logging.INFO)
log = logging.getLogger()
# log.setLevel(level=logging.INFO)
def filter(url, data):
    log.info("handling url '{}'".format(url))
    if "api.github.com" in url:
        import json
        log.info("url is a github api link, assuming json")
        return json.dumps(json.loads(data),indent=2)

    return data
