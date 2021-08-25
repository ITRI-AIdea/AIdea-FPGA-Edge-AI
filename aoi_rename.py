#!/usr/bin/env python3

#  Copyright 2021 Industrial Technology Research Institute
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

from os import rename
import csv


def main():
    print('Renaming training data ...')

    with open('train.csv', 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            src_path = f'./train_images/{row["ID"]}'
            dst_path = f'./train_images/{row["Label"]}.{row["ID"]}'
            try:
                rename(src=src_path, dst=dst_path)
            except FileNotFoundError as e:
                print(e)

    print('Done!')


if __name__ == '__main__':
    main()
