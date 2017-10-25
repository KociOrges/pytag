b'This module needs Python 3.4.0 or newer'

# Special variables #
__version__ = '1.0.0'
version_string = "pytag version %s" % __version__


# Internal modules #
__all__ = ['analysis', 'annotation', 'ontologies']
from trytouploadhelloworld.analysis import Analysis
from trytouploadhelloworld.annotation import *
from trytouploadhelloworld.ontologies import *
