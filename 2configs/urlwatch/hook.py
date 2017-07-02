import logging
logging.basicConfig(level=logging.INFO)
log = logging.getLogger()
log.setLevel(level=logging.INFO)

import re
import json

from urlwatch import filters


class JsonFilter(filters.RegexMatchFilter):
    MATCH = {'url': re.compile('https?://api.github.com/.*')}

    def filter(self, data):
        return json.dumps(json.loads(data),indent=2,sort_keys=True)
