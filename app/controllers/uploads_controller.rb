require 'aws-sdk'
require 'docx'

class UploadsController < ApplicationController
  before_action :set_upload, only: [:show, :edit, :update, :destroy, :download]


  def download
    s3 = Aws::S3::Client.new
    file = s3.get_object(bucket: ENV["S3_BUCKET"], key: @upload['s3_name'])

    send_data(file.body.read, :filename => "#{@upload.name}.#{@upload.file_extension}", :disposition => 'attachment')
  end

  # GET /uploads
  # GET /uploads.json
  def index
    @search = params[:search]
    if @search
      @uploads= Upload.search(@search)
    else
      @uploads = Upload.all
    end
  end

  # GET /uploads/1
  # GET /uploads/1.json
  def show
  end

  # GET /uploads/new
  def new
    @upload = Upload.new
  end

  # GET /uploads/1/edit
  def edit
  end

  # POST /uploads
  # POST /uploads.json
  def create


    temp_file_path = params['file'].tempfile.path
    inferred_type = infer_type(temp_file_path)
    random_name = SecureRandom.uuid

    upload_file(random_name, temp_file_path)

    @upload = Upload.new(upload_params)
    @upload['uploadDate'] = Time.now
    @upload['file_extension'] = inferred_type
    @upload['s3_name'] = random_name

    full_text = ''
    if(inferred_type == "docx")
      # Create a Docx::Document object for our existing docx file
      doc = Docx::Document.open(temp_file_path)
      doc.paragraphs.each do |p|
        full_text.concat(" ").concat(p.to_s)
      end
    end

    if(inferred_type == "pdf")
      reader = PDF::Reader.new(temp_file_path)
      reader.pages.each do |page|
        full_text.concat(" ").concat(page.text) 
      end
    end

    @upload['full_text'] = full_text

    respond_to do |format|
      if @upload.save
        format.html { redirect_to @upload, notice: 'Upload was successfully created.' }
        format.json { render :show, status: :created, location: @upload }
      else
        format.html { render :new }
        format.json { render json: @upload.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /uploads/1
  # PATCH/PUT /uploads/1.json
  def update
    respond_to do |format|
      if @upload.update(upload_params)
        format.html { redirect_to @upload, notice: 'Upload was successfully updated.' }
        format.json { render :show, status: :ok, location: @upload }
      else
        format.html { render :edit }
        format.json { render json: @upload.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /uploads/1
  # DELETE /uploads/1.json
  def destroy
    @upload.destroy
    respond_to do |format|
      format.html { redirect_to uploads_url, notice: 'Upload was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def upload_file(file_name, path_to_file)
      s3 = Aws::S3::Resource.new(region:'us-west-1')
      obj = s3.bucket(ENV["S3_BUCKET"]).object(file_name)
      obj.upload_file(path_to_file)
    end

    def infer_type(file_name)
      return file_name.split('.')[-1]
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_upload
      @upload = Upload.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def upload_params
      params.require(:upload).permit(:name, :description)
    end
end
