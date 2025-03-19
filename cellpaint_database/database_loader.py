import sqlite3
from sqlite3 import Error
from pathlib import Path
import numpy as np
from skimage import io


class DatabaseLoader:
    def __init__(self, db_file, data_root):
        self.db_file = db_file
        self.data_root = Path(data_root)
        self.conn = self.create_connection()

        cursor = self.conn.cursor()
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
        tables = cursor.fetchall()
        assert len(tables) == 1, "Database should only have one table"
        self.table_name = tables[0][0]
        print("Tables in the database:", tables)

        for table in tables:
            command = f"PRAGMA table_info({table[0]})"
            print(f"Table: {table}")
            cursor.execute(command)
            attributes = cursor.fetchall()
            for attr in attributes:
                print(
                    f"Attribute:{attr[1]}, Type:{attr[2]}, Default Val: {attr[4]}, Primary Key:{attr[5]}"
                )

    def create_connection(self):
        try:
            self.conn = sqlite3.connect(self.db_file)
            return self.conn
        except Error as e:
            print(e)

    def close_connection(self):
        if self.conn:
            self.conn.close()

    def get_image(self, plate, well, channel):
        cursor = self.conn.cursor()

        if type(well) == int:  # searching by site
            command = f"SELECT path_unmixed FROM images WHERE plate = {plate} AND site = {well} AND channel_num = {channel}"
            cursor.execute(command)
            rows = cursor.fetchall()
            assert len(rows) == 1, f"Expected 1 row, got {len(rows)}"
            path = rows[0][0]
        elif type(well) == tuple:
            row, column, field = well
            command = f"SELECT path_unmixed FROM images WHERE plate = {plate} AND row = '{row}' AND column = {column} AND field = {field} AND channel_num = {channel}"
            cursor.execute(command)
            rows = cursor.fetchall()
            assert len(rows) == 1, f"Expected 1 row, got {len(rows)}"
            path = rows[0][0]

        full_path = self.data_root / path

        return io.imread(full_path)

    def get_treatment(self, plate, well, channel):
        cursor = self.conn.cursor()

        if type(well) == int:  # searching by site
            command = f"SELECT treatment FROM images WHERE plate = {plate} AND site = {well} AND channel_num = {channel}"
            cursor.execute(command)
            rows = cursor.fetchall()
            assert len(rows) == 1, f"Expected 1 row, got {len(rows)}"
            treatment = rows[0][0]
        elif type(well) == tuple:
            row, column, field = well
            command = f"SELECT treatment FROM images WHERE plate = {plate} AND row = '{row}' AND column = {column} AND field = {field} AND channel_num = {channel}"
            cursor.execute(command)
            rows = cursor.fetchall()
            assert len(rows) == 1, f"Expected 1 row, got {len(rows)}"
            treatment = rows[0][0]

        return treatment

    def get_line(self, plate, well, channel):
        cursor = self.conn.cursor()

        if type(well) == int:  # searching by site
            command = f"SELECT line FROM images WHERE plate = {plate} AND site = {well} AND channel_num = {channel}"
            cursor.execute(command)
            rows = cursor.fetchall()
            assert len(rows) == 1, f"Expected 1 row, got {len(rows)}"
            line = rows[0][0]
        elif type(well) == tuple:
            row, column, field = well
            command = f"SELECT line FROM images WHERE plate = {plate} AND row = '{row}' AND column = {column} AND field = {field} AND channel_num = {channel}"
            cursor.execute(command)
            rows = cursor.fetchall()
            assert len(rows) == 1, f"Expected 1 row, got {len(rows)}"
            line = rows[0][0]

        return line
