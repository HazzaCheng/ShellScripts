from email.header import Header
from email.mime.text import MIMEText
import smtplib
from email.utils import parseaddr, formataddr
import sys


def _format_addr(s):
    name, addr = parseaddr(s)
    return formataddr((Header(name, 'utf-8').encode(), addr))


def send_plain_email(sender, passwd, receiver, smpt_server, filePath, subject, sender_name, receiver_name, ip):
    with open(filePath) as f:
        data = f.read()

    msg = MIMEText(data, 'plain', 'utf-8')
    msg['From'] = _format_addr('%s(%s) <%s>' % (sender_name, ip, sender))
    msg['To'] = _format_addr('%s <%s>' % (receiver_name, receiver))
    msg['Subject'] = Header(subject, 'utf-8').encode()

    server = smtplib.SMTP(smpt_server, 25)
    server.starttls()
    server.set_debuglevel(1)
    server.login(sender, passwd)
    server.sendmail(sender, [receiver], msg.as_string())
    server.quit()


if __name__ == '__main__':
    if len(sys.argv) < 10:
        print('There are not enough arguments!')
        print('You should use like the following:')
        print('python 3 sendPlainEmail [sender_address] [sender_password] [receiver_address] [SMPT_server_address] '
              '[email_content_location] [email_subject] [sender_name] [receiver_name] [your_ip]')
    else:
        send_plain_email(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4],
                         sys.argv[5], sys.argv[6], sys.argv[7], sys.argv[8], sys.argv[9])
