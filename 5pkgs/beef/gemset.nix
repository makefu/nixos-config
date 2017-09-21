{
  addressable = {
    dependencies = ["public_suffix"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0viqszpkggqi8hq87pqp0xykhvz60g99nwmkwsb0v45kc2liwxvk";
      type = "gem";
    };
    version = "2.5.2";
  };
  ansi = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14ims9zfal4gs2wpx2m5rd8zsrl2k794d359shkrsgg3fhr2a22l";
      type = "gem";
    };
    version = "1.5.0";
  };
  chunky_png = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0j0dngz6s0j3s3zaf9vrimjz65s9k7ad1c3xmmldr1vmz8sbd843";
      type = "gem";
    };
    version = "1.3.8";
  };
  daemons = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bmb4qrd95b5gl3ym5j3q6mf090209f4vkczggn49n56w6s6zldz";
      type = "gem";
    };
    version = "1.2.4";
  };
  data_objects = {
    dependencies = ["addressable"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19fw1ckqc5f1wc4r72qrymy2k6cmd8azbxpn61ksbsjqhzc2bgqd";
      type = "gem";
    };
    version = "0.10.17";
  };
  dm-core = {
    dependencies = ["addressable"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09x67ka6f1lxh4iwrg87iama0haq0d0z35gavvnvzpx9kn9pfbnw";
      type = "gem";
    };
    version = "1.2.1";
  };
  dm-do-adapter = {
    dependencies = ["data_objects" "dm-core"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1v84lsmsq8kawl8k4qz2h87xqc1sr10c08wwasrxbcgrkvp7qk4q";
      type = "gem";
    };
    version = "1.2.0";
  };
  dm-migrations = {
    dependencies = ["dm-core"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04hr8qgm4j1z5fg0cfpr8r6apvk5xykad0d0xqfg48rjv5rdwc0i";
      type = "gem";
    };
    version = "1.2.0";
  };
  dm-serializer = {
    dependencies = ["dm-core" "fastercsv" "json" "json_pure" "multi_json"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0mvpb2d4cniysw45d3c9xidjpdb3wmfl7x5lgvnsfm69wq24v5y4";
      type = "gem";
    };
    version = "1.2.2";
  };
  dm-sqlite-adapter = {
    dependencies = ["dm-do-adapter" "do_sqlite3"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0mq9xrw4jwb753sy8902rq9sfv62mzss2n3875g51i9acqy475hc";
      type = "gem";
    };
    version = "1.2.0";
  };
  do_sqlite3 = {
    dependencies = ["data_objects"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gxz54qjgwg6a2mkqpai28m0i5swbyxpr4qmh9x1nwf20lysrgcf";
      type = "gem";
    };
    version = "0.10.17";
  };
  em-websocket = {
    dependencies = ["eventmachine" "http_parser.rb"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bsw8vjz0z267j40nhbmrvfz7dvacq4p0pagvyp17jif6mj6v7n3";
      type = "gem";
    };
    version = "0.5.1";
  };
  erubis = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fj827xqjs91yqsydf0zmfyw9p4l2jz5yikg3mppz6d7fi8kyrb3";
      type = "gem";
    };
    version = "2.7.0";
  };
  espeak-ruby = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0d658zr53jibyrs5qnic7bfl6h69k5987s8asncsbnxwbzzilj6y";
      type = "gem";
    };
    version = "1.0.4";
  };
  eventmachine = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17jr1caa3ggg696dd02g2zqzdjqj9x9q2nl7va82l36f7c5v6k4z";
      type = "gem";
    };
    version = "1.0.9.1";
  };
  execjs = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yz55sf2nd3l666ms6xr18sm2aggcvmb8qr3v53lr4rir32y1yp1";
      type = "gem";
    };
    version = "2.7.0";
  };
  fastercsv = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1df3vfgw5wg0s405z0pj0rfcvnl9q6wak7ka8gn0xqg4cag1k66h";
      type = "gem";
    };
    version = "1.5.5";
  };
  filesize = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "061qmg82mm9xnmnq3b7gbi24g28xk62w0b0nw86gybd07m1jn989";
      type = "gem";
    };
    version = "0.1.1";
  };
  geoip = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "099hxng7h8i3pwibnassivj58iw1x7ygwq06qj6rx7j16iyz6rzx";
      type = "gem";
    };
    version = "1.6.3";
  };
  "http_parser.rb" = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15nidriy0v5yqfjsgsra51wmknxci2n2grliz78sf9pga3n0l7gi";
      type = "gem";
    };
    version = "0.6.0";
  };
  jsobfu = {
    dependencies = ["rkelly-remix"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1hchns89cfj0gggm2zbr7ghb630imxm2x2d21ffx2jlasn9xbkyk";
      type = "gem";
    };
    version = "0.4.2";
  };
  json = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qmj7fypgb9vag723w1a49qihxrcf5shzars106ynw2zk352gbv5";
      type = "gem";
    };
    version = "1.8.6";
  };
  json_pure = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vllrpm2hpsy5w1r7000mna2mhd7yfrmd8hi713lk0n9mv27bmam";
      type = "gem";
    };
    version = "1.8.6";
  };
  libv8 = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0271i5sfma05gvhmrmxqb0jj667bl6m54yd49ay6yrdbh1g4wpl1";
      type = "gem";
    };
    version = "3.16.14.19";
  };
  metasm = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gss57q4lv6l0jkih77zffrpjjzgkdcsy7b9nvvawyzknis9w4s5";
      type = "gem";
    };
    version = "1.0.3";
  };
  mime-types = {
    dependencies = ["mime-types-data"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0087z9kbnlqhci7fxh9f6il63hj1k02icq2rs0c6cppmqchr753m";
      type = "gem";
    };
    version = "3.1";
  };
  mime-types-data = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04my3746hwa4yvbx1ranhfaqkgf6vavi1kyijjnw8w3dy37vqhkm";
      type = "gem";
    };
    version = "3.2016.0521";
  };
  mini_portile2 = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13d32jjadpjj6d2wdhkfpsmy68zjx90p49bgf8f7nkpz86r1fr11";
      type = "gem";
    };
    version = "2.3.0";
  };
  mojo_magick = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1n4hzdyvaggzasxb55iqjd8sg6g84yc2dbaip0zzy7nwr5j5h8sm";
      type = "gem";
    };
    version = "0.5.6";
  };
  msfrpc-client = {
    dependencies = ["msgpack" "rex"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0q1x0xy857qm3sdxynp5p8kk7f6j25qjw1p28jh0y2qivc5ksik8";
      type = "gem";
    };
    version = "1.1.1";
  };
  msgpack = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ck7w17d6b4jbb8inh1q57bghi9cjkiaxql1d3glmj1yavbpmlh7";
      type = "gem";
    };
    version = "1.1.0";
  };
  multi_json = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1raim9ddjh672m32psaa9niw67ywzjbxbdb8iijx3wv9k5b0pk2x";
      type = "gem";
    };
    version = "1.12.2";
  };
  nokogiri = {
    dependencies = ["mini_portile2"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "105xh2zkr8nsyfaj2izaisarpnkrrl9000y3nyflg9cbzrfxv021";
      type = "gem";
    };
    version = "1.8.1";
  };
  parseconfig = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0br2g9k6zc4ygah52aa8cwvpnnkszia29bnvnr8bhpk3rdzi2vmq";
      type = "gem";
    };
    version = "1.0.8";
  };
  public_suffix = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0snaj1gxfib4ja1mvy3dzmi7am73i0mkqr0zkz045qv6509dhj5f";
      type = "gem";
    };
    version = "3.0.0";
  };
  qr4r = {
    dependencies = ["mojo_magick" "rqrcode"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ya71fxhmx2zfsmflmqh6xm9jwgjxamsj9d3h1kjp21w4vca0s30";
      type = "gem";
    };
    version = "0.4.1";
  };
  rack = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19m7aixb2ri7p1n0iqaqx8ldi97xdhvbxijbyrrcdcl6fv5prqza";
      type = "gem";
    };
    version = "1.6.8";
  };
  rack-protection = {
    dependencies = ["rack"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cvb21zz7p9wy23wdav63z5qzfn4nialik22yqp6gihkgfqqrh5r";
      type = "gem";
    };
    version = "1.5.3";
  };
  rainbow = {
    dependencies = ["rake"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08w2ghc5nv0kcq5b257h7dwjzjz1pqcavajfdx2xjyxqsvh2y34w";
      type = "gem";
    };
    version = "2.2.2";
  };
  rake = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0mfqgpp3m69s5v1rd51lfh5qpjwyia5p4rg337pw8c8wzm6pgfsw";
      type = "gem";
    };
    version = "12.1.0";
  };
  rb-readline = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14w79a121czmvk1s953qfzww30mqjb2zc0k9qhi0ivxxk3hxg6wy";
      type = "gem";
    };
    version = "0.5.5";
  };
  ref = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04p4pq4sikly7pvn30dc7v5x2m7fqbfwijci4z1y6a1ilwxzrjii";
      type = "gem";
    };
    version = "2.0.0";
  };
  rex = {
    dependencies = ["filesize" "jsobfu" "json" "metasm" "nokogiri" "rb-readline" "robots"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0kxacxq4l1gcqbw1izg2qqvdhxl6b5779a2qa2jk24f6x96bpi68";
      type = "gem";
    };
    version = "2.0.11";
  };
  rexec = {
    dependencies = ["rainbow"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ihc0a6gj4i3287fjm86cn2ax4hlznyk5aqxrhjxkf4y9kabc3in";
      type = "gem";
    };
    version = "1.6.3";
  };
  rkelly-remix = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1g7hjl9nx7f953y7lncmfgp0xgxfxvgfm367q6da9niik6rp1y3j";
      type = "gem";
    };
    version = "0.0.7";
  };
  robots = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "141gvihcr2c0dpzl3dqyh8kqc9121prfdql2iamaaw0mf9qs3njs";
      type = "gem";
    };
    version = "0.10.1";
  };
  rqrcode = {
    dependencies = ["chunky_png"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0h1pnnydgs032psakvg3l779w3ghbn08ajhhhw19hpmnfhrs8k0a";
      type = "gem";
    };
    version = "0.10.1";
  };
  rubydns = {
    dependencies = ["eventmachine" "rexec"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1mav6589kpqh37wlipkh1nww6ipbw4kzja2crz216v25wwjrbpx2";
      type = "gem";
    };
    version = "0.7.3";
  };
  rubyzip = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06js4gznzgh8ac2ldvmjcmg9v1vg9llm357yckkpylaj6z456zqz";
      type = "gem";
    };
    version = "1.2.1";
  };
  sinatra = {
    dependencies = ["rack" "rack-protection" "tilt"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0byxzl7rx3ki0xd7aiv1x8mbah7hzd8f81l65nq8857kmgzj1jqq";
      type = "gem";
    };
    version = "1.4.8";
  };
  term-ansicolor = {
    dependencies = ["tins"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1b1wq9ljh7v3qyxkk8vik2fqx2qzwh5lval5f92llmldkw7r7k7b";
      type = "gem";
    };
    version = "1.6.0";
  };
  therubyracer = {
    dependencies = ["libv8" "ref"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1g95bzs2axjglyjyj6xvsywqgr80bnzlkw7mddxx1fdrak5wni2q";
      type = "gem";
    };
    version = "0.12.3";
  };
  thin = {
    dependencies = ["daemons" "eventmachine" "rack"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nagbf9pwy1vg09k6j4xqhbjjzrg5dwzvkn4ffvlj76fsn6vv61f";
      type = "gem";
    };
    version = "1.7.2";
  };
  tilt = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0020mrgdf11q23hm1ddd6fv691l51vi10af00f137ilcdb2ycfra";
      type = "gem";
    };
    version = "2.0.8";
  };
  tins = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09whix5a7ics6787zrkwjmp16kqyh6560p9f317syks785805f7s";
      type = "gem";
    };
    version = "1.15.0";
  };
  uglifier = {
    dependencies = ["execjs"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wmqvn4xncw6h3d5gp2a44170zwxfyj3iq4rsjp16zarvzbdmgnz";
      type = "gem";
    };
    version = "3.2.0";
  };
}