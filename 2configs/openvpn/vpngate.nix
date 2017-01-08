{ pkgs, ... }:
{
  services.openvpn.servers.vpngate-japan = {
    config = ''
      dev tun
      proto udp
      remote vpn311786078.opengw.net 1573
      cipher AES-128-CBC
      auth SHA1
      resolv-retry infinite
      nobind
      persist-key
      persist-tun
      client
      verb 3
      #auth-user-pass

      <ca>
      -----BEGIN CERTIFICATE-----
      MIIDHDCCAgSgAwIBAgIFAIRyJXcwDQYJKoZIhvcNAQELBQAwRTEYMBYGA1UEAwwP
      a3JqejV3YXE1YXliLmpwMRwwGgYDVQQKDBNlcnp6eTBxZnhwaiAxNHQzZGJnMQsw
      CQYDVQQGEwJVUzAeFw0xNzAxMDMwMjE3MDNaFw0yNDA1MDEwMjE3MDNaMEUxGDAW
      BgNVBAMMD2tyano1d2FxNWF5Yi5qcDEcMBoGA1UECgwTZXJ6enkwcWZ4cGogMTR0
      M2RiZzELMAkGA1UEBhMCVVMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
      AQDBRSiY0DMxjUZWRtpq892vPdk+TQ4Pgxnscfzsw3MMJBGaNhIzLvNSzUdFWJq1
      p6SpCD8pJsxQifDzM5t7KGqWUmY2vgucAaGCZtbrqijm74rJOEfyF3D8stYBkTmb
      AOBkRXtxoi62M+d3xgNox1VaDXndgOqQhnj4INChWf4b8lc33I/2NmwVa2d9jh+e
      Qx1OsnbYGi9EM/RfTKfGcPxtusN8IEzwo2q0s7PLxgiIbCZs3aAMZIvOdi9CkFkQ
      +T9wQlC1BJwbWFXqUPR2r4ugE0iYepjhEd19KuaGqW0PYivHGM9lRU2JjfJujBeF
      vaOjMExvi+Mwl78Qmm7wbH1BAgMBAAGjEzARMA8GA1UdEwEB/wQFMAMBAf8wDQYJ
      KoZIhvcNAQELBQADggEBABoJhTO8WHB6MEWbsTXUVYG/Ino1TQTkha/0BtJ02Mdi
      AV0QLOjZM0Q5F2Tg2puRK92nDp7VLA8VUqlrvLqBh6ljMEEhEwaVkV/ZigqUmGlV
      nOE8NABj1mmsJSeh8DQjNclPkkOrKC6sudk9NsU4I51kDPr3M6jCd+/vBoZ6/lVR
      oOLVnHOhWVsOdw/I792j4DEpVB8U8g2LhYdAJZNoKvfc6F32TEZphFxU3yDA4Kb5
      BqC8IU3O5eL7vrkVpvHdzaO+Q6wJ148/PbWXpsxm8mI39I6sQ820mGw/PGrmBAgh
      WgJ52Kr48Vq0TVmdew0mz+xzU7SnpndmhVyFk9nN3c8=
      -----END CERTIFICATE-----
      </ca>

      <cert>
      -----BEGIN CERTIFICATE-----
      MIICxjCCAa4CAQAwDQYJKoZIhvcNAQEFBQAwKTEaMBgGA1UEAxMRVlBOR2F0ZUNs
      aWVudENlcnQxCzAJBgNVBAYTAkpQMB4XDTEzMDIxMTAzNDk0OVoXDTM3MDExOTAz
      MTQwN1owKTEaMBgGA1UEAxMRVlBOR2F0ZUNsaWVudENlcnQxCzAJBgNVBAYTAkpQ
      MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5h2lgQQYUjwoKYJbzVZA
      5VcIGd5otPc/qZRMt0KItCFA0s9RwReNVa9fDRFLRBhcITOlv3FBcW3E8h1Us7RD
      4W8GmJe8zapJnLsD39OSMRCzZJnczW4OCH1PZRZWKqDtjlNca9AF8a65jTmlDxCQ
      CjntLIWk5OLLVkFt9/tScc1GDtci55ofhaNAYMPiH7V8+1g66pGHXAoWK6AQVH67
      XCKJnGB5nlQ+HsMYPV/O49Ld91ZN/2tHkcaLLyNtywxVPRSsRh480jju0fcCsv6h
      p/0yXnTB//mWutBGpdUlIbwiITbAmrsbYnjigRvnPqX1RNJUbi9Fp6C2c/HIFJGD
      ywIDAQABMA0GCSqGSIb3DQEBBQUAA4IBAQChO5hgcw/4oWfoEFLu9kBa1B//kxH8
      hQkChVNn8BRC7Y0URQitPl3DKEed9URBDdg2KOAz77bb6ENPiliD+a38UJHIRMqe
      UBHhllOHIzvDhHFbaovALBQceeBzdkQxsKQESKmQmR832950UCovoyRB61UyAV7h
      +mZhYPGRKXKSJI6s0Egg/Cri+Cwk4bjJfrb5hVse11yh4D9MHhwSfCOH+0z4hPUT
      Fku7dGavURO5SVxMn/sL6En5D+oSeXkadHpDs+Airym2YHh15h0+jPSOoR6yiVp/
      6zZeZkrN43kuS73KpKDFjfFPh8t4r1gOIjttkNcQqBccusnplQ7HJpsk
      -----END CERTIFICATE-----
      </cert>

      <key>
      -----BEGIN RSA PRIVATE KEY-----
      MIIEpAIBAAKCAQEA5h2lgQQYUjwoKYJbzVZA5VcIGd5otPc/qZRMt0KItCFA0s9R
      wReNVa9fDRFLRBhcITOlv3FBcW3E8h1Us7RD4W8GmJe8zapJnLsD39OSMRCzZJnc
      zW4OCH1PZRZWKqDtjlNca9AF8a65jTmlDxCQCjntLIWk5OLLVkFt9/tScc1GDtci
      55ofhaNAYMPiH7V8+1g66pGHXAoWK6AQVH67XCKJnGB5nlQ+HsMYPV/O49Ld91ZN
      /2tHkcaLLyNtywxVPRSsRh480jju0fcCsv6hp/0yXnTB//mWutBGpdUlIbwiITbA
      mrsbYnjigRvnPqX1RNJUbi9Fp6C2c/HIFJGDywIDAQABAoIBAERV7X5AvxA8uRiK
      k8SIpsD0dX1pJOMIwakUVyvc4EfN0DhKRNb4rYoSiEGTLyzLpyBc/A28Dlkm5eOY
      fjzXfYkGtYi/Ftxkg3O9vcrMQ4+6i+uGHaIL2rL+s4MrfO8v1xv6+Wky33EEGCou
      QiwVGRFQXnRoQ62NBCFbUNLhmXwdj1akZzLU4p5R4zA3QhdxwEIatVLt0+7owLQ3
      lP8sfXhppPOXjTqMD4QkYwzPAa8/zF7acn4kryrUP7Q6PAfd0zEVqNy9ZCZ9ffho
      zXedFj486IFoc5gnTp2N6jsnVj4LCGIhlVHlYGozKKFqJcQVGsHCqq1oz2zjW6LS
      oRYIHgECgYEA8zZrkCwNYSXJuODJ3m/hOLVxcxgJuwXoiErWd0E42vPanjjVMhnt
      KY5l8qGMJ6FhK9LYx2qCrf/E0XtUAZ2wVq3ORTyGnsMWre9tLYs55X+ZN10Tc75z
      4hacbU0hqKN1HiDmsMRY3/2NaZHoy7MKnwJJBaG48l9CCTlVwMHocIECgYEA8jby
      dGjxTH+6XHWNizb5SRbZxAnyEeJeRwTMh0gGzwGPpH/sZYGzyu0SySXWCnZh3Rgq
      5uLlNxtrXrljZlyi2nQdQgsq2YrWUs0+zgU+22uQsZpSAftmhVrtvet6MjVjbByY
      DADciEVUdJYIXk+qnFUJyeroLIkTj7WYKZ6RjksCgYBoCFIwRDeg42oK89RFmnOr
      LymNAq4+2oMhsWlVb4ejWIWeAk9nc+GXUfrXszRhS01mUnU5r5ygUvRcarV/T3U7
      TnMZ+I7Y4DgWRIDd51znhxIBtYV5j/C/t85HjqOkH+8b6RTkbchaX3mau7fpUfds
      Fq0nhIq42fhEO8srfYYwgQKBgQCyhi1N/8taRwpk+3/IDEzQwjbfdzUkWWSDk9Xs
      H/pkuRHWfTMP3flWqEYgW/LW40peW2HDq5imdV8+AgZxe/XMbaji9Lgwf1RY005n
      KxaZQz7yqHupWlLGF68DPHxkZVVSagDnV/sztWX6SFsCqFVnxIXifXGC4cW5Nm9g
      va8q4QKBgQCEhLVeUfdwKvkZ94g/GFz731Z2hrdVhgMZaU/u6t0V95+YezPNCQZB
      wmE9Mmlbq1emDeROivjCfoGhR3kZXW1pTKlLh6ZMUQUOpptdXva8XxfoqQwa3enA
      M7muBbF0XN7VO80iJPv+PmIZdEIAkpwKfi201YB+BafCIuGxIF50Vg==
      -----END RSA PRIVATE KEY-----
      </key>

    '';
    autoStart = false;
    updateResolvConf = false;
  };
  services.openvpn.servers.vpngate-usa1 = {
    config = ''
      dev tun
      proto udp
      remote vpn854005480.opengw.net 1434
      cipher AES-128-CBC
      auth SHA1
      resolv-retry infinite
      nobind
      persist-key
      persist-tun
      client
      verb 3

      <ca>
      -----BEGIN CERTIFICATE-----
      MIIDEDCCAfigAwIBAgIFFzQRkTQwDQYJKoZIhvcNAQELBQAwPzEUMBIGA1UEAwwL
      MWh6NWFzMWYuanAxGjAYBgNVBAoMEXYyMjZvdmdjIHJ0YTc3NXR6MQswCQYDVQQG
      EwJVUzAeFw0xNjEwMjIxODE4MjRaFw0yNDAxMTkxODE4MjRaMD8xFDASBgNVBAMM
      CzFoejVhczFmLmpwMRowGAYDVQQKDBF2MjI2b3ZnYyBydGE3NzV0ejELMAkGA1UE
      BhMCVVMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDX6yJXCpA95oPU
      /vO1wD6UiJnZfDB1fjJOa8gwgK6qbLHo5Cx2gEmUzYOGTlT2Fbser2kHA3xTRxDu
      L+1dufGp8zEi116I5SkLDKRQqO/8h1bWQO7MB4k6K0YlYrWJGTLCanZB3zIS3F7P
      2qCALdZ40Y1QUQlMEqzg1exeaMDdgOPXDKe1f2L06RpZKQ3ozzHlFgMKamWlLk+/
      N+Flo0s5Z2cfgUBqoBmuXVGBX4ZFxozSojcpREp+sLstdJ56vsW3KztTYTjj6y9Q
      MXNadwsTI6sB/kmex3R0phFlw/ucloXQTecbqWDvJrumQHjiI1HqP95c3Z/y4PoD
      lZvUb15HAgMBAAGjEzARMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQAD
      ggEBAJKHl41QHHuCBC8c3/0PNed3Y0+qRCnB7JB6SraYT5VRSA1dcpvmCESZE3WC
      Sn7OaIBpIm6dBKFkCJgS7lEoMYzmazlfv/RpeRj8fmzcaOcoZdWHk/e1Mkzt5UAz
      2rsBxDgWmVJfmUR2gnEltvSWQKLdM/F+GB7LNckg58n4yBViCF3pp1HTq1Q59laV
      QQNG8dSqy9EY8WI7oj/I60G6Gcd2dOt9+RXCCA3RZ/9zSGEi4AmDV7oRNfGEdmcy
      YN2K13NlMO+Sdh4S90KVxGOXo2Q0G9HDWJ60f/I+3bxQFb+n85WAM38ZqX/9D72S
      YD3YtJG14xlsO1BDPUgm1t6H8gc=
      -----END CERTIFICATE-----
      </ca>

      <cert>
      -----BEGIN CERTIFICATE-----
      MIICxjCCAa4CAQAwDQYJKoZIhvcNAQEFBQAwKTEaMBgGA1UEAxMRVlBOR2F0ZUNs
      aWVudENlcnQxCzAJBgNVBAYTAkpQMB4XDTEzMDIxMTAzNDk0OVoXDTM3MDExOTAz
      MTQwN1owKTEaMBgGA1UEAxMRVlBOR2F0ZUNsaWVudENlcnQxCzAJBgNVBAYTAkpQ
      MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5h2lgQQYUjwoKYJbzVZA
      5VcIGd5otPc/qZRMt0KItCFA0s9RwReNVa9fDRFLRBhcITOlv3FBcW3E8h1Us7RD
      4W8GmJe8zapJnLsD39OSMRCzZJnczW4OCH1PZRZWKqDtjlNca9AF8a65jTmlDxCQ
      CjntLIWk5OLLVkFt9/tScc1GDtci55ofhaNAYMPiH7V8+1g66pGHXAoWK6AQVH67
      XCKJnGB5nlQ+HsMYPV/O49Ld91ZN/2tHkcaLLyNtywxVPRSsRh480jju0fcCsv6h
      p/0yXnTB//mWutBGpdUlIbwiITbAmrsbYnjigRvnPqX1RNJUbi9Fp6C2c/HIFJGD
      ywIDAQABMA0GCSqGSIb3DQEBBQUAA4IBAQChO5hgcw/4oWfoEFLu9kBa1B//kxH8
      hQkChVNn8BRC7Y0URQitPl3DKEed9URBDdg2KOAz77bb6ENPiliD+a38UJHIRMqe
      UBHhllOHIzvDhHFbaovALBQceeBzdkQxsKQESKmQmR832950UCovoyRB61UyAV7h
      +mZhYPGRKXKSJI6s0Egg/Cri+Cwk4bjJfrb5hVse11yh4D9MHhwSfCOH+0z4hPUT
      Fku7dGavURO5SVxMn/sL6En5D+oSeXkadHpDs+Airym2YHh15h0+jPSOoR6yiVp/
      6zZeZkrN43kuS73KpKDFjfFPh8t4r1gOIjttkNcQqBccusnplQ7HJpsk
      -----END CERTIFICATE-----
      </cert>

      <key>
      -----BEGIN RSA PRIVATE KEY-----
      MIIEpAIBAAKCAQEA5h2lgQQYUjwoKYJbzVZA5VcIGd5otPc/qZRMt0KItCFA0s9R
      wReNVa9fDRFLRBhcITOlv3FBcW3E8h1Us7RD4W8GmJe8zapJnLsD39OSMRCzZJnc
      zW4OCH1PZRZWKqDtjlNca9AF8a65jTmlDxCQCjntLIWk5OLLVkFt9/tScc1GDtci
      55ofhaNAYMPiH7V8+1g66pGHXAoWK6AQVH67XCKJnGB5nlQ+HsMYPV/O49Ld91ZN
      /2tHkcaLLyNtywxVPRSsRh480jju0fcCsv6hp/0yXnTB//mWutBGpdUlIbwiITbA
      mrsbYnjigRvnPqX1RNJUbi9Fp6C2c/HIFJGDywIDAQABAoIBAERV7X5AvxA8uRiK
      k8SIpsD0dX1pJOMIwakUVyvc4EfN0DhKRNb4rYoSiEGTLyzLpyBc/A28Dlkm5eOY
      fjzXfYkGtYi/Ftxkg3O9vcrMQ4+6i+uGHaIL2rL+s4MrfO8v1xv6+Wky33EEGCou
      QiwVGRFQXnRoQ62NBCFbUNLhmXwdj1akZzLU4p5R4zA3QhdxwEIatVLt0+7owLQ3
      lP8sfXhppPOXjTqMD4QkYwzPAa8/zF7acn4kryrUP7Q6PAfd0zEVqNy9ZCZ9ffho
      zXedFj486IFoc5gnTp2N6jsnVj4LCGIhlVHlYGozKKFqJcQVGsHCqq1oz2zjW6LS
      oRYIHgECgYEA8zZrkCwNYSXJuODJ3m/hOLVxcxgJuwXoiErWd0E42vPanjjVMhnt
      KY5l8qGMJ6FhK9LYx2qCrf/E0XtUAZ2wVq3ORTyGnsMWre9tLYs55X+ZN10Tc75z
      4hacbU0hqKN1HiDmsMRY3/2NaZHoy7MKnwJJBaG48l9CCTlVwMHocIECgYEA8jby
      dGjxTH+6XHWNizb5SRbZxAnyEeJeRwTMh0gGzwGPpH/sZYGzyu0SySXWCnZh3Rgq
      5uLlNxtrXrljZlyi2nQdQgsq2YrWUs0+zgU+22uQsZpSAftmhVrtvet6MjVjbByY
      DADciEVUdJYIXk+qnFUJyeroLIkTj7WYKZ6RjksCgYBoCFIwRDeg42oK89RFmnOr
      LymNAq4+2oMhsWlVb4ejWIWeAk9nc+GXUfrXszRhS01mUnU5r5ygUvRcarV/T3U7
      TnMZ+I7Y4DgWRIDd51znhxIBtYV5j/C/t85HjqOkH+8b6RTkbchaX3mau7fpUfds
      Fq0nhIq42fhEO8srfYYwgQKBgQCyhi1N/8taRwpk+3/IDEzQwjbfdzUkWWSDk9Xs
      H/pkuRHWfTMP3flWqEYgW/LW40peW2HDq5imdV8+AgZxe/XMbaji9Lgwf1RY005n
      KxaZQz7yqHupWlLGF68DPHxkZVVSagDnV/sztWX6SFsCqFVnxIXifXGC4cW5Nm9g
      va8q4QKBgQCEhLVeUfdwKvkZ94g/GFz731Z2hrdVhgMZaU/u6t0V95+YezPNCQZB
      wmE9Mmlbq1emDeROivjCfoGhR3kZXW1pTKlLh6ZMUQUOpptdXva8XxfoqQwa3enA
      M7muBbF0XN7VO80iJPv+PmIZdEIAkpwKfi201YB+BafCIuGxIF50Vg==
      -----END RSA PRIVATE KEY-----
      </key>
    '';
    autoStart = false;
    updateResolvConf = false;
  };
  services.openvpn.servers.vpngate-usa2 = {
    config = ''
      dev tun

      proto udp

      remote vpn444417710.opengw.net 1195

      cipher AES-128-CBC
      auth SHA1

      resolv-retry infinite
      nobind
      persist-key
      persist-tun
      client
      verb 3
      #auth-user-pass

      <ca>
      -----BEGIN CERTIFICATE-----
      MIIDIzCCAgugAwIBAgIEMERikDANBgkqhkiG9w0BAQsFADBJMR8wHQYDVQQDDBZz
      cmlnbGh6dWwxamtraDdtY2UubmV0MRkwFwYDVQQKDBBkY2c3MTQ4bnQgb3Rmdjd0
      MQswCQYDVQQGEwJVUzAeFw0xNjEyMDUyMzMzNTdaFw0yMTA4MjkyMzMzNTdaMEkx
      HzAdBgNVBAMMFnNyaWdsaHp1bDFqa2toN21jZS5uZXQxGTAXBgNVBAoMEGRjZzcx
      NDhudCBvdGZ2N3QxCzAJBgNVBAYTAlVTMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
      MIIBCgKCAQEA8ASCMZyeVeTkRELTVJKzWFufi9LFq6N1euhOK9KNLeCn5OJXxeJ6
      FoRD2QtDHwHscEPrJ2uIVqqxvm/uuZ7aWKXVuRzCbYeQih6tUK4M/Q55iKeynPMt
      vCBH28IasH33fGbw95S82nXEwWK6tR3+WdIcHFJ7RZz1QkmsWOzI/vn2pNeyZCIG
      QjuFJEfiSTNorqhR29vJhWR3pRLWgorAQav7ukgAdQqKIldX0LQr4BoN5HLDe7AC
      9jO3Xs6dQieyxnF183XVigZZ+cfaD9kK1m/+4JKWNphIGi9bsGRumjJwQgrv35CA
      6+FCMXRUM7PQljjlgDhdW4VeYtX0tg46uwIDAQABoxMwETAPBgNVHRMBAf8EBTAD
      AQH/MA0GCSqGSIb3DQEBCwUAA4IBAQDUjycraBUWrVvtQ4touYR1T9+msLhFc3RO
      clHnyw+2PEyNdTy8ra13dUXkWqIgWnyxj8CSFJmfLCdxuQrNEQ8jF7rJNGqujVI1
      +xjao5fIt33EAwg2CFDs5DETEcwb7/lJIs1uwwiDPIZrmXyoL9My9ZZ8DKkRy4LS
      1+GZx4Y9v/G1AFKfQ4n//v8s+SYQS3JZxspEONj8M9VkKjuYonFR6eegKWo37QaY
      hy9+4qTRGbviET1si+fZ0LVweyfG3t0Fg8BJn+1YP9kpLJdjOtzKCFbdIrjY3XSS
      3ehfN8C5mGWk0pQMWJs+xYIfB0OvDRgehICw0PIvps8Sv8gu4Bve
      -----END CERTIFICATE-----

      </ca>

      <cert>
      -----BEGIN CERTIFICATE-----
      MIICxjCCAa4CAQAwDQYJKoZIhvcNAQEFBQAwKTEaMBgGA1UEAxMRVlBOR2F0ZUNs
      aWVudENlcnQxCzAJBgNVBAYTAkpQMB4XDTEzMDIxMTAzNDk0OVoXDTM3MDExOTAz
      MTQwN1owKTEaMBgGA1UEAxMRVlBOR2F0ZUNsaWVudENlcnQxCzAJBgNVBAYTAkpQ
      MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5h2lgQQYUjwoKYJbzVZA
      5VcIGd5otPc/qZRMt0KItCFA0s9RwReNVa9fDRFLRBhcITOlv3FBcW3E8h1Us7RD
      4W8GmJe8zapJnLsD39OSMRCzZJnczW4OCH1PZRZWKqDtjlNca9AF8a65jTmlDxCQ
      CjntLIWk5OLLVkFt9/tScc1GDtci55ofhaNAYMPiH7V8+1g66pGHXAoWK6AQVH67
      XCKJnGB5nlQ+HsMYPV/O49Ld91ZN/2tHkcaLLyNtywxVPRSsRh480jju0fcCsv6h
      p/0yXnTB//mWutBGpdUlIbwiITbAmrsbYnjigRvnPqX1RNJUbi9Fp6C2c/HIFJGD
      ywIDAQABMA0GCSqGSIb3DQEBBQUAA4IBAQChO5hgcw/4oWfoEFLu9kBa1B//kxH8
      hQkChVNn8BRC7Y0URQitPl3DKEed9URBDdg2KOAz77bb6ENPiliD+a38UJHIRMqe
      UBHhllOHIzvDhHFbaovALBQceeBzdkQxsKQESKmQmR832950UCovoyRB61UyAV7h
      +mZhYPGRKXKSJI6s0Egg/Cri+Cwk4bjJfrb5hVse11yh4D9MHhwSfCOH+0z4hPUT
      Fku7dGavURO5SVxMn/sL6En5D+oSeXkadHpDs+Airym2YHh15h0+jPSOoR6yiVp/
      6zZeZkrN43kuS73KpKDFjfFPh8t4r1gOIjttkNcQqBccusnplQ7HJpsk
      -----END CERTIFICATE-----

      </cert>

      <key>
      -----BEGIN RSA PRIVATE KEY-----
      MIIEpAIBAAKCAQEA5h2lgQQYUjwoKYJbzVZA5VcIGd5otPc/qZRMt0KItCFA0s9R
      wReNVa9fDRFLRBhcITOlv3FBcW3E8h1Us7RD4W8GmJe8zapJnLsD39OSMRCzZJnc
      zW4OCH1PZRZWKqDtjlNca9AF8a65jTmlDxCQCjntLIWk5OLLVkFt9/tScc1GDtci
      55ofhaNAYMPiH7V8+1g66pGHXAoWK6AQVH67XCKJnGB5nlQ+HsMYPV/O49Ld91ZN
      /2tHkcaLLyNtywxVPRSsRh480jju0fcCsv6hp/0yXnTB//mWutBGpdUlIbwiITbA
      mrsbYnjigRvnPqX1RNJUbi9Fp6C2c/HIFJGDywIDAQABAoIBAERV7X5AvxA8uRiK
      k8SIpsD0dX1pJOMIwakUVyvc4EfN0DhKRNb4rYoSiEGTLyzLpyBc/A28Dlkm5eOY
      fjzXfYkGtYi/Ftxkg3O9vcrMQ4+6i+uGHaIL2rL+s4MrfO8v1xv6+Wky33EEGCou
      QiwVGRFQXnRoQ62NBCFbUNLhmXwdj1akZzLU4p5R4zA3QhdxwEIatVLt0+7owLQ3
      lP8sfXhppPOXjTqMD4QkYwzPAa8/zF7acn4kryrUP7Q6PAfd0zEVqNy9ZCZ9ffho
      zXedFj486IFoc5gnTp2N6jsnVj4LCGIhlVHlYGozKKFqJcQVGsHCqq1oz2zjW6LS
      oRYIHgECgYEA8zZrkCwNYSXJuODJ3m/hOLVxcxgJuwXoiErWd0E42vPanjjVMhnt
      KY5l8qGMJ6FhK9LYx2qCrf/E0XtUAZ2wVq3ORTyGnsMWre9tLYs55X+ZN10Tc75z
      4hacbU0hqKN1HiDmsMRY3/2NaZHoy7MKnwJJBaG48l9CCTlVwMHocIECgYEA8jby
      dGjxTH+6XHWNizb5SRbZxAnyEeJeRwTMh0gGzwGPpH/sZYGzyu0SySXWCnZh3Rgq
      5uLlNxtrXrljZlyi2nQdQgsq2YrWUs0+zgU+22uQsZpSAftmhVrtvet6MjVjbByY
      DADciEVUdJYIXk+qnFUJyeroLIkTj7WYKZ6RjksCgYBoCFIwRDeg42oK89RFmnOr
      LymNAq4+2oMhsWlVb4ejWIWeAk9nc+GXUfrXszRhS01mUnU5r5ygUvRcarV/T3U7
      TnMZ+I7Y4DgWRIDd51znhxIBtYV5j/C/t85HjqOkH+8b6RTkbchaX3mau7fpUfds
      Fq0nhIq42fhEO8srfYYwgQKBgQCyhi1N/8taRwpk+3/IDEzQwjbfdzUkWWSDk9Xs
      H/pkuRHWfTMP3flWqEYgW/LW40peW2HDq5imdV8+AgZxe/XMbaji9Lgwf1RY005n
      KxaZQz7yqHupWlLGF68DPHxkZVVSagDnV/sztWX6SFsCqFVnxIXifXGC4cW5Nm9g
      va8q4QKBgQCEhLVeUfdwKvkZ94g/GFz731Z2hrdVhgMZaU/u6t0V95+YezPNCQZB
      wmE9Mmlbq1emDeROivjCfoGhR3kZXW1pTKlLh6ZMUQUOpptdXva8XxfoqQwa3enA
      M7muBbF0XN7VO80iJPv+PmIZdEIAkpwKfi201YB+BafCIuGxIF50Vg==
      -----END RSA PRIVATE KEY-----

      </key>
    '';
    autoStart = false;
    updateResolvConf = false;
  };
}
