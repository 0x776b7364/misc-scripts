# installation from ubuntu docker:
# apt-get update
# apt-get install python3 python3-pip
# pip3 install certstream
# python3 my-certstream-watchdog.py

# forked from https://gist.github.com/PaulSec/7cc3fd51cd956c46bf0d85010b638ed3

import certstream

keywords = ['domain1', 'domain2']

def extract_domains(domains):
    res = []
    for domain in domains:
        for keyword in keywords:
            if keyword in domain:
                res.append(domain)
    return res

def print_callback(message, context):
    domains = message['data']['leaf_cert']['all_domains']
    res = extract_domains(domains)
    if len(res) > 0:
        for result in res:
                print(result)

def on_open(instance):
    # Instance is the CertStreamClient instance that was opened
    print("Connection successfully established!")

def on_error(instance, exception):
    # Instance is the CertStreamClient instance that barfed
    print("Exception in CertStreamClient! -> {}".format(exception))

certstream.listen_for_events(print_callback, on_open=on_open, on_error=on_error)
