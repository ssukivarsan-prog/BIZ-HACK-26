import re
import sys

def main():
    try:
        with open('lib/l10n/app_translations.dart', 'r', encoding='utf-8') as f:
            content = f.read()

        # Fix the \\' issue
        content = content.replace("'Browse today\\\\'s stock", "'Browse today\\'s stock")
        content = content.replace("we\\\\'ll send", "we\\'ll send")
        content = content.replace("Don\\\\'t have", "Don\\'t have")

        # Parse the dart file and remove duplicates
        lines = content.split('\n')
        out_lines = []
        seen_keys = set()

        for line in lines:
            # Match lines that look like key-value pairs in the map
            # e.g., 'Key': 'Value',
            match = re.match(r"^\s*'(.+?)'\s*:\s*'.*?'\s*,?\s*$", line)
            if match:
                key = match.group(1)
                if key in seen_keys:
                    print(f"Removing duplicate key: {key}")
                    continue
                seen_keys.add(key)
            out_lines.append(line)

        with open('lib/l10n/app_translations.dart', 'w', encoding='utf-8') as f:
            f.write('\n'.join(out_lines))
            
        print('Duplicates removed successfully')
    except Exception as e:
        print(f'Error: {e}')
        sys.exit(1)

if __name__ == '__main__':
    main()
