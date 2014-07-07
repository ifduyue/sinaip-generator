SinaIP Generator
===================

This is for generating binary file which can be used by sinaip.xxx (e.g. `sinaip-go <https://github.com/ifduyue/sinaip-go>`_).

You can do it yourself, or download directly from the `Releases <https://github.com/ifduyue/sinaip-generator/releases>`_ page.


File Format
-------------

+-------------------------------------+
| File Format                         |
+=====================================+
| 4: data offset                      |
+-------------------------------------+
| 4: index offset                     |
+-------------------------------------+
| ?: text (null terminated strings)   |
+-------------------------------------+
| N*16: data (offsets to text)        |
+-------------------------------------+
| N*4: index                          |
+-------------------------------------+

License
--------

Licensed under AGPLv3, see LICENSE.
