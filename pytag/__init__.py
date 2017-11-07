b'This module needs Python 3.4.2 or newer'

# Special variables #
__version__ = '0.1.0'
version_string = "pytag version %s" % __version__


# Internal modules #
__all__ = ['analysis', 'annotation', 'ontologies']
from pytag.analysis import *
from pytag.annotation import *
from pytag.ontologies import *
