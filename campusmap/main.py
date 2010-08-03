#!/usr/bin/env python
#
# Copyright 2010 David Lindquist and Michael Kelly
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from google.appengine.ext import blobstore
from google.appengine.ext import webapp
from google.appengine.ext.webapp import blobstore_handlers
from google.appengine.ext.webapp import template
from google.appengine.ext.webapp import util
from google.appengine.ext.webapp.util import run_wsgi_app

import campusmap
import map_handlers

import logging
import urllib

class UploadHandler(blobstore_handlers.BlobstoreUploadHandler):
    def get(self):
        upload_url = blobstore.create_upload_url('/upload')
        self.response.out.write('<html><body>')
        self.response.out.write('<form action="%s" method="POST" enctype="multipart/form-data">' % upload_url)
        self.response.out.write("""Upload File: <input type="file" name="file"><br> <input type="submit" 
            name="submit" value="Submit"> </form></body></html>""")
    def post(self):
        upload_files = self.get_uploads('file')  # 'file' is file upload field in the form
        blob_info = upload_files[0]
        self.redirect('/p/k/%s' % blob_info.key())

class PathHandler(blobstore_handlers.BlobstoreDownloadHandler):
    def get(self, x, y, zoom):
        logging.info("get path %s %s %s", x, y, zoom)
        pathinfo = campusmap.PathInfo.fromSrcDst(x, y)
        if pathinfo:
            if pathinfo.blob_id is not None:
                self.send_blob(PathByKeyHandler.get_blob(pathinfo.blob_id))
            else:
                logging.error("no blob_id for pathinfo %s", pathinfo)
                self.error(404)
        else:
            logging.error("pathinfo for %s %s %s not found", x, y, zoom)
            self.error(404)

class PathByKeyHandler(blobstore_handlers.BlobstoreDownloadHandler):
    @staticmethod
    def get_blob(key):
        key = str(urllib.unquote(key))
        return blobstore.BlobInfo.get(key)

    def get(self, key):
        self.send_blob(PathByKeyHandler.get_blob(key))

class MainHandler(webapp.RequestHandler):
    def get(self):
        response = """
<html>
<head>
    <title>CampusMap</title>
</head>
<body>
<h1>CampusMap</h1>
<p>Foo.</p>
</body>
</html>
"""
        self.response.out.write(response)

def main():
    application = webapp.WSGIApplication([('/', MainHandler),
                                          ("/map/?", map_handlers.ViewHandler),
                                          ('/upload', UploadHandler),
                                          ('/p/k/([^/]+)', PathByKeyHandler),
                                          ('/p/(\d+)-(\d+)-(\d+)', PathHandler)],
                                         debug=True)
    util.run_wsgi_app(application)


if __name__ == '__main__':
    main()
