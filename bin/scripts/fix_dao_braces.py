from pathlib import Path

d = Path(__file__).resolve().parents[2] / "server" / "src" / "main" / "java" / "edp" / "davinci" / "dao"
for f in d.glob("*Mapper.java"):
    t = f.read_text(encoding="utf-8")
    n = t.replace('{{"', '{"').replace('"}}', '"}')
    n = n.replace("value = {{", "value = {")
    if n != t:
        f.write_text(n, encoding="utf-8")
        print("fixed", f.name)
