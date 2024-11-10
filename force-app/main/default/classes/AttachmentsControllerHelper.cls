public with sharing class AttachmentsControllerHelper {
    public static String formatBytes(Integer bytes) {
        Decimal KB = 1024;
        Decimal MB = KB * 1024;
        Decimal GB = MB * 1024;
        Decimal TB = GB * 1024;
        
        Decimal result;
        String unit;

        if (bytes >= GB) {
            result = bytes / GB;
            unit = 'GB';
        } else if (bytes >= MB) {
            result = bytes / MB;
            unit = 'MB';
        } else if (bytes >= KB) {
            result = bytes / KB;
            unit = 'KB';
        } else {
            return bytes + ' Bytes';
        }

        return result.setScale(1) + ' ' + unit;
    }

    public static String mapFileIcon(String fileExtention) {
        if (fileExtention == null) {
            return 'doctype:unknown';
        }

        fileExtention = fileExtention.toLowerCase();

        switch on fileExtention {
            when 'pdf' {
                return 'doctype:pdf';
            }
            when 'doc', 'docx' {
                return 'doctype:word';
            }
            when 'xls', 'xlsx' {
                return 'doctype:excel';
            }
            when 'ppt', 'pptx' {
                return 'doctype:ppt';
            }
            when 'txt' {
                return 'doctype:txt';
            }
            when 'csv' {
                return 'doctype:csv';
            }
            when 'zip', 'rar' {
                return 'doctype:zip';
            }
            when 'jpg', 'jpeg', 'png', 'gif', 'bmp' {
                return 'doctype:image';
            }
            when 'mp3', 'wav', 'flac' {
                return 'doctype:audio';
            }
            when 'mp4', 'mov', 'avi', 'mkv' {
                return 'doctype:video';
            }
            when 'html', 'htm' {
                return 'doctype:html';
            }
            when 'xml' {
                return 'doctype:xml';
            }
            when else {
                return 'doctype:unknown';
            }
        }
    }
}