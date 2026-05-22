import pymysql
for pwd in ["", "root", "123456", "password", "mysql"]:
    try:
        c = pymysql.connect(host="127.0.0.1", user="root", password=pwd, charset="utf8mb4")
        print("OK password=%r" % pwd)
        cur = c.cursor()
        cur.execute("SHOW DATABASES")
        for row in cur.fetchall():
            if "davinci" in row[0].lower() or row[0] in ("mysql", "information_schema"):
                print(" ", row[0])
        c.close()
        break
    except Exception as e:
        print("FAIL password=%r: %s" % (pwd, e))
