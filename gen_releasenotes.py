#!/usr/bin/python
"""
Skript to create releasenotes automatically from bugzilla
"""

__version__='$Release:$'

import urllib2
import urlparse
import StringIO
from optparse import OptionParser

def requrl(query_name, queries, scheme, netloc):
    import sys
    import cgi
    
    _data=list()
    for _key, _values in queries[query_name]["params"].items():
        for _value in _values:
            _data.append("%s=%s" %(cgi.escape(_key), cgi.escape(_value)))
    _url=urlparse.urlunparse((scheme, netloc, queries[query_name]["path"], "", "", ""))
    _in=urllib2.urlopen(_url, "&".join(_data))
    sys.stderr.write("Requesting %s?%s\n" %(_url, "&".join(_data)))
    return _in.readlines()

import sys
import os.path
_path= os.path.dirname(sys.argv[0])

parser = OptionParser(description=__doc__, version=__version__)
parser.add_option("-s", "--server",   dest="server",   default="bugzilla.atix.de", help="Set the bugzillaserver")
parser.add_option("-P", "--protocol", dest="protocol", default="https", help="set the protocol http/https to access the bugzilla url")
parser.add_option("-p", "--product",  dest="product",  default=[], action="append", help="Specify the products to be included in these releasenotes")
parser.add_option("-x", "--xslt",     dest="xslt",     default=os.path.join(_path, "../../resources/xslt/bugzilla2docbook-releasenotes.xsl"), help="Specify the xslt the xml output of the bugzilla should be converted with. Default is docbook output")
parser.add_option("-X", "--onlyxml",  dest="onlyxml",  default=False, action="store_true", help="Output the XML queried from bugzilla. No xslt applied.")

(options, args) = parser.parse_args()
    
queries={ 'ids': { 
                  'path': 'buglist.cgi',
                  'params': {'status_whiteboard': [''], 
                             'deadlineto': [''], 
                             'long_desc_type': ['substring'], 
                             'bug_file_loc': [''], 
                             'bugidtype': ['include'], 
                             'cmdtype': ['doit'], 
                             'email2': [''], 
                             'email1': [''], 
                             'votes': [''], 
                             'query_format': ['advanced'], 
                             'product': options.product,
                             'emailqa_contact2': ['1'], 
                             'short_desc': [''], 
                             'chfieldvalue': [''], 
                             'chfieldto': ['Now'], 
                             'long_desc': [''], 
                             'bug_file_loc_type': ['allwordssubstr'], 
                             'emailassigned_to1': ['1'], 
                             'ctype': ['csv'], 
                             'emailassigned_to2': ['1'], 
                             'bug_id': [''], 
                             'emailreporter2': ['1'], 
                             'short_desc_type': ['allwordssubstr'], 
                             'status_whiteboard_type': ['allwordssubstr'], 
                             'deadlinefrom': [''], 
                             'emailcc2': ['1'], 
                             'chfieldfrom': [''], 
                             'emailtype2': ['substring'], 
                             'emailtype1': ['substring'], 
                             'order': ['Reuse+same+sort+as+last+time'],
                             'bug_status': ['CLOSED'], 
                             'resolution': ['FIXED'], 
                             'field0-0-0': ['flagtypes.name'], 
                             'type0-0-0': ['regexp'], 
                             'value0-0-0': ['comoonics-[0-9]%2B.*\%2B%24'], 
#                             'field0-1-0': ['version'], 
#                             'type0-1-0': ['notequals'], 
#                             'value0-1-0': ['unspecified'], 
                             }
                  },
            'buglist': {
                        'path': 'show_bug.cgi',
                        'params': { 'ctype': ['xml'],
                                    'order': ['bugs.severity']
                                  }
                   },
}

_lines=requrl("ids", queries, options.protocol, options.server)[1:]
_bugids=list()
for _line in _lines:
    _bugids.append(_line.split(",")[0])
sys.stderr.write("Found bugids: %s\n" %_bugids)
queries["buglist"]["params"]["id"]=_bugids
_buf2=StringIO.StringIO("".join(requrl("buglist", queries, options.protocol, options.server))).getvalue()
if options.onlyxml or not options.xslt or options.xslt=="":
    print _buf2
else: 
    import libxslt
    import libxml2
    n_doc = libxml2.parseMemory(_buf2, len(_buf2))
    style = libxml2.parseFile(options.xslt)
    xslt_style = libxslt.parseStylesheetDoc(style)
    params={}
    res = xslt_style.applyStylesheet(n_doc, params)
    str_buff=xslt_style.saveResultToString(res)
    print str_buff
    xslt_style.freeStylesheet()
    n_doc.freeDoc()
    #res.dump(sys.stdout)
    res.freeDoc()
