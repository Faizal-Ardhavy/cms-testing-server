module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: [:show, :update, :destroy]
      skip_before_action :verify_authenticity_token, only: [:create, :update, :destroy, :upload_file, :update_file_put, :update_file_patch]
      STORAGE_PATH = Rails.root.join("storage", "files")

      def index
        users = User.all
        render json: users
      end

      def show
        render json: @user
      end

      def create
        user = User.new(user_params)
        if user.save
          render json: user, status: :created
        else
          render json: user.errors, status: :unprocessable_entity
        end
      end

      def update
        if @user.update(user_params)
          render json: @user
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @user.destroy
        head :no_content
      end


      def upload_file
        if params[:file].present?
          uploaded_file = params[:file]
          filename = "#{SecureRandom.hex}_#{uploaded_file.original_filename}"
          filepath = Rails.root.join("storage", "files", filename)

          # Simpan file ke storage/files
          FileUtils.mkdir_p(File.dirname(filepath)) unless File.directory?(File.dirname(filepath))
          File.open(filepath, "wb") do |file|
            file.write(uploaded_file.read)
          end

          render json: { message: "File uploaded successfully", filename: filename }, status: :ok
        else
          render json: { error: "No file provided" }, status: :unprocessable_entity
        end
      end

      def update_file_put
        if params[:file].present?
          filename = "#{SecureRandom.hex}_#{params[:file].original_filename}"
          filepath = STORAGE_PATH.join(filename)

          # Hapus semua file lama di storage/files
          FileUtils.rm_rf(Dir["#{STORAGE_PATH}/*"])

          # Simpan file baru
          save_file(filepath, params[:file])

          render json: { message: "File replaced successfully", filename: filename }, status: :ok
        else
          render json: { error: "No file provided" }, status: :unprocessable_entity
        end
      end

      # PATCH - Tambahkan file baru tanpa menghapus file lama
      def update_file_patch
        if params[:file].present?
          filename = "#{SecureRandom.hex}_#{params[:file].original_filename}"
          filepath = STORAGE_PATH.join(filename)

          # Simpan file baru tanpa menghapus yang lama
          save_file(filepath, params[:file])

          render json: { message: "File uploaded successfully", filename: filename }, status: :ok
        else
          render json: { error: "No file provided" }, status: :unprocessable_entity
        end
      end

      # Simpan file ke storage/files/
      
      private

      def save_file(filepath, uploaded_file)
        FileUtils.mkdir_p(File.dirname(filepath)) unless File.directory?(File.dirname(filepath))
        File.open(filepath, "wb") { |file| file.write(uploaded_file.read) }
      end

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:name, :email)
      end
    end
  end
end
