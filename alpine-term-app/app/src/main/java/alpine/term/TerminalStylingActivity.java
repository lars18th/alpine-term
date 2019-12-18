/*
*************************************************************************
Alpine Term - a VM-based terminal emulator.
Copyright (C) 2019  Leonid Plyushch <leonid.plyushch@gmail.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*************************************************************************
*/
package alpine.term;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.util.Pair;
import android.view.WindowManager;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.Toast;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/**
 * A menu for changing terminal color scheme and font.
 */
@SuppressWarnings("WeakerAccess")
public class TerminalStylingActivity extends Activity {

    private static final String DEFAULT_FILENAME = "Default";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Avoid dim behind:
        getWindow().clearFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND);
        setContentView(R.layout.styling_layout);

        final Button colorSpinner = findViewById(R.id.color_spinner);
        final Button fontSpinner = findViewById(R.id.font_spinner);

        final ArrayAdapter<Selectable> colorAdapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item);

        colorSpinner.setOnClickListener(v -> {
            final AlertDialog dialog = new AlertDialog.Builder(TerminalStylingActivity.this).setAdapter(colorAdapter, (dialog1, which) -> copyFile(colorAdapter.getItem(which), true)).create();
            dialog.show();
        });

        final ArrayAdapter<Selectable> fontAdapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item);
        fontSpinner.setOnClickListener(v -> {
            AlertDialog.Builder builder = new AlertDialog.Builder(TerminalStylingActivity.this);
            builder.setAdapter(fontAdapter, (dialog12, which) -> copyFile(fontAdapter.getItem(which), false));
            final AlertDialog dialog = builder.create();
            dialog.show();
        });

        List<Selectable> colorList = new ArrayList<>();
        List<Selectable> fontList = new ArrayList<>();

        for (String assetType : new String[]{"color_schemes", "fonts"}) {
            boolean isColors = assetType.equals("color_schemes");

            String assetsFileExtension = isColors ? ".properties" : ".ttf";
            List<Selectable> currentList = isColors ? colorList : fontList;

            currentList.add(new Selectable(isColors ? DEFAULT_FILENAME : DEFAULT_FILENAME));

            try {
                for (String f : Objects.requireNonNull(getAssets().list(assetType))) {
                    if (f.endsWith(assetsFileExtension)) currentList.add(new Selectable(f));
                }
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

        Pair<List<Selectable>, List<Selectable>> result = Pair.create(colorList, fontList);

        colorAdapter.addAll(result.first);
        fontAdapter.addAll(result.second);
    }

    private void copyFile(Selectable mCurrentSelectable, boolean colors) {
        final String outputFileName = colors ? "console_colors.prop" : "console_font.ttf";

        try {
            final String assetsFolder = colors ? "color_schemes" : "fonts";
            File destinationFile = new File(getApplicationContext().getFilesDir().getAbsolutePath() + "/" + outputFileName);
            boolean defaultChoice = mCurrentSelectable.fileName.equals(DEFAULT_FILENAME);

            // Write to existing file to keep symlink if this is used.
            try (FileOutputStream out = new FileOutputStream(destinationFile)) {
                if (defaultChoice) {
                    if (colors) {
                        byte[] comment = "# Using default color theme.".getBytes(StandardCharsets.UTF_8);
                        out.write(comment);
                    }
                } else {
                    try (InputStream in = getAssets().open(assetsFolder + "/" + mCurrentSelectable.fileName)) {
                        byte[] buffer = new byte[4096];
                        int len;

                        while ((len = in.read(buffer)) > 0) {
                            out.write(buffer, 0, len);
                        }
                    }
                }
            }

            sendBroadcast(new Intent().setAction(TerminalActivity.INTENT_ACTION_RELOAD_STYLING));
        } catch (Exception e) {
            Log.e(Config.LOG_TAG, "Failed to write " + outputFileName, e);
            Toast.makeText(this, R.string.style_toast_install_failed, Toast.LENGTH_LONG).show();
        }
    }

    private static class Selectable {
        final String displayName;
        final String fileName;

        public Selectable(final String fileName) {
            String name = fileName.replace('-', ' ');
            int dotIndex = name.lastIndexOf('.');
            if (dotIndex != -1) name = name.substring(0, dotIndex);

            this.displayName = capitalize(name);
            this.fileName = fileName;
        }

        @Override
        public String toString() {
            return displayName;
        }

        private static String capitalize(String str) {
            boolean lastWhitespace = true;
            char[] chars = str.toCharArray();

            for (int i = 0; i < chars.length; i++) {
                if (Character.isLetter(chars[i])) {
                    if (lastWhitespace) {
                        chars[i] = Character.toUpperCase(chars[i]);
                    }

                    lastWhitespace = false;
                } else {
                    lastWhitespace = Character.isWhitespace(chars[i]);
                }
            }

            return new String(chars);
        }
    }
}
