 { pkgs, ... }:
 {
   fonts = {
     fontDir.enable = true;
     enableGhostscriptFonts = true;
     packages = with pkgs; [
       inconsolata  # monospaced
       ubuntu_font_family  # Ubuntu fonts
       unifont # some international languages
       dejavu_fonts
       terminus_font
     ];
   };
 }
