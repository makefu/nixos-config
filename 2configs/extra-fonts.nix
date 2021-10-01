 { pkgs, ... }:
 {
   fonts = {
     fontDir.enable = true;
     enableGhostscriptFonts = true;
     fonts = with pkgs; [
       inconsolata  # monospaced
       ubuntu_font_family  # Ubuntu fonts
       unifont # some international languages
       dejavu_fonts
       terminus_font
     ];
   };
 }
