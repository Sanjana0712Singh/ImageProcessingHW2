#include "image.h"
#include <cstring>
#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>

using namespace std;

image::image()
{
	data.numRows = data.numColumns = 0; 
	data.redChannel.clear();
	data.greenChannel.clear();
	data.blueChannel.clear();
}
/*-----------------------------------------------------------------------**/
image::image(image &img)
{
	this->copyImage(img);
}

/*-----------------------------------------------------------------------**/
image::image(int rows, int columns) 
{
	this->data.numRows = rows;
	this->data.numColumns = columns; 
	this->resize (rows, columns);
}

/*-----------------------------------------------------------------------**/
image::~image() 
{
	this->deleteImage();
}

/*-----------------------------------------------------------------------**/
bool image::isInbounds (int row, int col) 
{
	if ((row < 0) || (col < 0) || (col >= data.numColumns) || (row >= data.numRows))
		return false;
	else 
		return true;
}

/*-----------------------------------------------------------------------**/
void image::deleteImage() 
{
	this->data.numRows = this->data.numColumns = 0; 
	this->data.redChannel.clear();
	this->data.greenChannel.clear();
	this->data.blueChannel.clear();
}

/*-----------------------------------------------------------------------**/
void image::copyImage(image &img)
{
	this->resize(img.getNumberOfRows(), img.getNumberOfColumns());
	for (int i=0; i<img.getNumberOfRows(); i++)
		for (int j=0; j<img.getNumberOfColumns(); j++)
		{
			this->setPixel(i, j, RED, img.getPixel(i, j, RED));
			this->setPixel(i, j, GREEN, img.getPixel(i, j, GREEN));
			this->setPixel(i, j, BLUE, img.getPixel(i, j, BLUE));
		}
}

/*-----------------------------------------------------------------------**/
void image::resize (int numberOfRows, int numberOfColumns) 
{
	data.numRows = numberOfRows;
	data.numColumns = numberOfColumns;
	data.redChannel.resize (numberOfRows*numberOfColumns);
	data.greenChannel.resize (numberOfRows*numberOfColumns);
	data.blueChannel.resize (numberOfRows*numberOfColumns);
}

/*-----------------------------------------------------------------------**/
void image::setNumberOfRows(int rows) 
{
	data.numRows = rows;
}

/*-----------------------------------------------------------------------**/
void image::setNumberOfColumns(int columns) 
{
	data.numColumns = columns;
}

/*-----------------------------------------------------------------------**/
void image::setPixel(const int row, const int col, const int value) 
{
	data.redChannel [row * data.numColumns + col] = value;
	data.greenChannel [row * data.numColumns + col] = value;
	data.blueChannel [row * data.numColumns + col] = value;
}

/*-----------------------------------------------------------------------**/
void image::setPixel(const int row, const int col, const int rgb, const int value) 
{
	if (rgb == RED)
		data.redChannel [row * data.numColumns + col] = value;
	else if (rgb == GREEN)
		data.greenChannel [row * data.numColumns + col] = value;
	else if (rgb == BLUE)
		data.blueChannel [row * data.numColumns + col] = value;
}

/*-----------------------------------------------------------------------**/
int image::getPixel(const int row, const int col) 
{
	return data.redChannel [row * data.numColumns + col];
}

/*-----------------------------------------------------------------------**/
int image::getPixel(const int row, const int col, const int rgb) 
{
	if (rgb == RED)
		return data.redChannel [row * data.numColumns + col];
	else if (rgb == GREEN)
		return data.greenChannel [row * data.numColumns + col];
	else if (rgb == BLUE)
		return data.blueChannel [row * data.numColumns + col];
	else
		return -1;
}

/*-----------------------------------------------------------------------**/
int image::getNumberOfRows() 
{
	return data.numRows;
}

/*-----------------------------------------------------------------------**/
int image::getNumberOfColumns() 
{
	return data.numColumns;
}

/*-----------------------------------------------------------------------**/
vector<int>* image::getChannel(int rgb) 
{
	if (rgb == RED)
		return &data.redChannel;
	else if (rgb == GREEN)
		return &data.greenChannel;
	else if (rgb == BLUE)
		return &data.blueChannel;
	else
		return NULL;
}

/*-----------------------------------------------------------------------**/
bool image::setChannel(int rgb, vector<int> &channel) 
{
	if (rgb == RED)
		data.redChannel = channel;
	else if (rgb == GREEN)
		data.greenChannel = channel;
	else if (rgb == BLUE)
		data.blueChannel = channel;
	else
		return false;
	return true;
}

/*-----------------------------------------------------------------------**/
bool image::save(char* file) 
{
	ofstream pgm_file(file, ios::out | ios::binary);
	if (pgm_file.is_open()) 
	{
		// FIX: Correct header identification based on file extension
		if (strstr(file, ".ppm")) {
			pgm_file << "P6" << endl; 
		} else {
			pgm_file << "P5" << endl;
		}

		pgm_file << data.numColumns << " " << data.numRows << endl;
		pgm_file << "255" << endl;

		if (strstr(file, ".ppm")) 
		{
			/* Write Color Image (P6) */
			unsigned char *buffer = new unsigned char[data.numRows * data.numColumns * 3];
			for (int i = 0; i < data.numRows * data.numColumns; i++) {
				buffer[i * 3] = (unsigned char)data.redChannel[i];
				buffer[i * 3 + 1] = (unsigned char)data.greenChannel[i];
				buffer[i * 3 + 2] = (unsigned char)data.blueChannel[i];
			}
			pgm_file.write((char*)buffer, data.numRows * data.numColumns * 3);
			delete[] buffer;
		}
		else 
		{
			/* Write Gray-level Image (P5) */
			unsigned char *buffer = new unsigned char[data.numRows * data.numColumns];
			for (int i = 0; i < data.numRows * data.numColumns; i++) {
				buffer[i] = (unsigned char)data.redChannel[i];
			}
			pgm_file.write((char*)buffer, data.numRows * data.numColumns);
			delete[] buffer;
		}

		pgm_file.close();
		return true;
	}
	return false;
}

/*-----------------------------------------------------------------------**/
bool image::read(char* file) 
{
	int row, col, i;
	unsigned char r, g, b;
	char header[100];
	ifstream pgm_file(file, ios::in | ios::binary);

	if (!pgm_file.is_open()) {
		fprintf(stderr, "Can't open file: %s\n", file);
		return false;
	}

	pgm_file >> header;
	pgm_file >> col >> row;
	pgm_file >> i;
	pgm_file.get(); // skip the newline after 255

	this->resize(row, col);

	if (strcmp(header, "P5") == 0) 
	{	/* Gray-level Image */
		char * buffer = new char [row*col];
		pgm_file.read(buffer, row*col);

		for(i = 0; i < row*col; i++){
			r = (unsigned char)buffer[i];
			data.redChannel [i] = r;
			data.greenChannel [i] = r;
			data.blueChannel [i] = r;
		}
		delete[] buffer;
	}
	else if (strcmp(header, "P6") == 0)
	{	/* Color Image */
		char * buffer = new char [row*col*3];
		pgm_file.read(buffer, row*col*3);

		for(i = 0; i < row*col; i++){
			r = (unsigned char)buffer[i*3];
			g = (unsigned char)buffer[i*3+1];
			b = (unsigned char)buffer[i*3+2];
			data.redChannel [i] = r;
			data.greenChannel [i] = g;
			data.blueChannel [i] = b;
		}
		delete[] buffer;
	} 

	pgm_file.close();
	return true;
}

/*-----------------------------------------------------------------------**/
int image::getint(FILE *fp) 
{
	int item, i, flag;
	/* Logic for reading integers from file... truncated for brevity as per source */
	return 0; 
}

/*-----------------------------------------------------------------------**/
bool image::save(const char* file) {
    return save(const_cast<char*>(file));
}
