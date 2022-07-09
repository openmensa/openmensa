# Creating a parser

This document describes briefly the important steps for creating a new OpenMensa parser and adding the represented new canteen with its menu to OpenMensa.

Afterwards these new data can be accessed in all OpenMensa tools (Website, iOS-App, Android-App, ...).

You should have read [Understand the OpenMensa Parser concept](understand.md).

It is recommended to first read to whole document to know the process itself with all its requirements. Afterwards you can do it step by step.

## Find The Data

Parsers do not create the canteen data. They receive the data from original sources. Most Studentenwerk provide meal information on there website or via a newsletter. For some canteens there are existing apps. They need an API or something like that to receive the displayed information. Maybe this can be accessed/parsed also by the OpenMensa parser.

For now I assume that a website should be used as data source. It is the common case.

## Decide How To Parse The Data

We need to transfer the meal information into the [standardized OpenMensa feed format](/feed/v2). To be able to do that we need to parse the original ones. This depends on the kind of data source you have. It is every easy for an existing API (JSON parser or something) and difficult for PDF documents.

Depending on your data you should look for libraries that support the parsing and choose your programming language afterwards.

For websites I recommend a tool for error tolerant HTML parsing, like [BeautifulSoup][bs4]. There is no general way to create a parser for a specific website. It depends very on your input data. Take a look at [a collection of parsers][om-parsers] for inspiration.

But some general tips:

- Try to make as few assumptions about the input data as possible - e.g. try to find the canteen data by HTML id or CSS class and not by walking thought the DOM tree.
- If you need to make assumptions, write your parser in such a way, that you get exceptions when these assumptions are wrong. So you get a notice when you have to update your parser.

## Write And Test Your Parser

Now you should be able to create your parser. If you use Python as programming language, you can use the [pyopenmensa][pyom-doc] library to create the OpenMensa feed. It implements also some common parsing tasks (like dates or meal notes)

Afterwards test that the created XML is a valid OpenMensa feed (XML validation, e.g. [using Validome][validome-xml]) and check that the meal information are the correct ones.

## Deploy Your Parser

OpenMensa accesses the registered feeds via HTTP. Therefore the created parser needs to be deployed somewhere and be accessible from the internet. If you can not host the parser yourself, you can look for free hosting services (like Google's app engine) or ask in the [OpenMensa community][om-contact] for help.

If the parser is deployed, you should be able to validate the generated XML feeds via URL.

## Register The New Canteens

At first you have to become an OpenMensa developer. Therefore log in OpenMensa. And provide an email address in your profile page. Afterwards you have additional links in your profile, like "Meine Mensen".

On the "Meine Mensen" page you can register new canteens. You have to provide some meta information about the canteen like name, position and the URL to your
parser.

## Monitor Your Work

Because the data sources changes from time to time, you should have an eye on your parser. OpenMensa informs you via email about every fetch errors for you parser. You should also check that the feed data matches the original data - especially in the first days.

[bs4]: http://www.crummy.com/software/BeautifulSoup/
[om-parsers]: https://github.com/mswart/openmensa-parsers
[validome-xml]: http://www.validome.org/xml/validate/
[pyom]: https://github.com/mswart/pyopenmensa
[pyom-doc]: http://pyom.devtation.de
[om-contact]: http://openmensa.org
